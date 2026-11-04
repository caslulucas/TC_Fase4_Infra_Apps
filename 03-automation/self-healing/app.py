import os
from datetime import datetime, timezone

from flask import Flask, jsonify, request
from kubernetes import client, config

app = Flask(__name__)

TARGET_NAMESPACE = os.getenv("TARGET_NAMESPACE", "monitoring")
TARGET_DEPLOYMENT = os.getenv("TARGET_DEPLOYMENT", "grafana")

config.load_incluster_config()
apps = client.AppsV1Api()


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.post("/heal")
def heal():
    payload = request.get_json(silent=True) or {}

    if payload.get("status") != "firing":
        return jsonify({
            "status": "ignored",
            "reason": "alert is not firing",
        })

    restarted_at = datetime.now(timezone.utc).isoformat()

    patch = {
        "spec": {
            "template": {
                "metadata": {
                    "annotations": {
                        "togglemaster.io/restartedAt": restarted_at
                    }
                }
            }
        }
    }

    apps.patch_namespaced_deployment(
        name=TARGET_DEPLOYMENT,
        namespace=TARGET_NAMESPACE,
        body=patch,
    )

    app.logger.warning(
        "SELF-HEALING triggered: deployment=%s namespace=%s timestamp=%s",
        TARGET_DEPLOYMENT,
        TARGET_NAMESPACE,
        restarted_at,
    )

    return jsonify({
        "status": "healing-triggered",
        "deployment": TARGET_DEPLOYMENT,
        "namespace": TARGET_NAMESPACE,
        "restartedAt": restarted_at,
    })