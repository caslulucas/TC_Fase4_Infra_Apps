package main

import (
	"context"
	"fmt"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

const serviceName = "evaluation-service"

func initTracerProvider(
	ctx context.Context,
) (*sdktrace.TracerProvider, error) {
	endpoint := os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT")
	if endpoint == "" {
		endpoint = "http://localhost:4318"
	}

	traceEndpoint := endpoint + "/v1/traces"
	exporter, err := otlptracehttp.New(
		ctx,
		otlptracehttp.WithEndpointURL(traceEndpoint),
	)
	if err != nil {
		return nil, fmt.Errorf(
			"erro ao criar exporter OTLP: %w",
			err,
		)
	}

	res, err := resource.New(
		ctx,
		resource.WithAttributes(
			attribute.String(
				"service.name",
				serviceName,
			),
			attribute.String(
				"deployment.environment",
				getEnvironment(),
			),
		),
	)
	if err != nil {
		return nil, fmt.Errorf(
			"erro ao criar resource OTel: %w",
			err,
		)
	}

	tracerProvider := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)

	otel.SetTracerProvider(tracerProvider)

	otel.SetTextMapPropagator(
		propagation.NewCompositeTextMapPropagator(
			propagation.TraceContext{},
			propagation.Baggage{},
		),
	)

	return tracerProvider, nil
}

func getEnvironment() string {
	environment := os.Getenv("DEPLOYMENT_ENVIRONMENT")
	if environment == "" {
		return "local"
	}

	return environment
}
