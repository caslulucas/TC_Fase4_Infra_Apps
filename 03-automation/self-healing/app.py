import os
from datetime import datetime, timezone
from threading import Lock

from flask import Flask, jsonify, request
from kubernetes import client, config

app = Flask(__name__)

TARGET_NAMESPACE = os.getenv(
    "TARGET_NAMESPACE",
    "monitoring",
)

TARGET_DEPLOYMENT = os.getenv(
    "TARGET_DEPLOYMENT",
    "grafana",
)

COOLDOWN_SECONDS = int(
    os.getenv(
        "COOLDOWN_SECONDS",
        "600",
    )
)

last_healing_at = None
healing_lock = Lock()

config.load_incluster_config()

apps = client.AppsV1Api()


@app.get("/health")
def health():
    return jsonify(
        {
            "status": "ok",
            "target_namespace": TARGET_NAMESPACE,
            "target_deployment": TARGET_DEPLOYMENT,
            "cooldown_seconds": COOLDOWN_SECONDS,
        }
    )


@app.post("/heal")
def heal():
    global last_healing_at

    payload = request.get_json(silent=True) or {}

    alert_status = payload.get("status")

    if alert_status != "firing":
        app.logger.info(
            "SELF-HEALING ignored: alert status=%s",
            alert_status,
        )

        return jsonify(
            {
                "status": "ignored",
                "reason": "alert-is-not-firing",
                "alertStatus": alert_status,
            }
        )

    with healing_lock:
        now = datetime.now(timezone.utc)

        if last_healing_at is not None:
            elapsed = (
                now - last_healing_at
            ).total_seconds()

            if elapsed < COOLDOWN_SECONDS:
                remaining = int(
                    COOLDOWN_SECONDS - elapsed
                )

                app.logger.warning(
                    "SELF-HEALING ignored: cooldown active, "
                    "remaining=%ss",
                    remaining,
                )

                return jsonify(
                    {
                        "status": "ignored",
                        "reason": "cooldown-active",
                        "remainingSeconds": remaining,
                    }
                )

        restarted_at = now.isoformat()

        patch = {
            "spec": {
                "template": {
                    "metadata": {
                        "annotations": {
                            "togglemaster.io/restartedAt":
                                restarted_at
                        }
                    }
                }
            }
        }

        try:
            apps.patch_namespaced_deployment(
                name=TARGET_DEPLOYMENT,
                namespace=TARGET_NAMESPACE,
                body=patch,
            )

        except client.ApiException as exc:
            app.logger.exception(
                "SELF-HEALING failed: deployment=%s "
                "namespace=%s",
                TARGET_DEPLOYMENT,
                TARGET_NAMESPACE,
            )

            return jsonify(
                {
                    "status": "error",
                    "reason": "kubernetes-patch-failed",
                    "details": str(exc),
                }
            ), 500

        last_healing_at = now

        app.logger.warning(
            "SELF-HEALING triggered: "
            "deployment=%s namespace=%s timestamp=%s",
            TARGET_DEPLOYMENT,
            TARGET_NAMESPACE,
            restarted_at,
        )

        return jsonify(
            {
                "status": "healing-triggered",
                "deployment": TARGET_DEPLOYMENT,
                "namespace": TARGET_NAMESPACE,
                "restartedAt": restarted_at,
                "cooldownSeconds": COOLDOWN_SECONDS,
            }
        )