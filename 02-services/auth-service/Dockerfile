FROM golang:1.26-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" \
    -o /app/auth-service .
    

FROM alpine:3.20

RUN apk add --no-cache ca-certificates \
    && adduser -D -H -s /sbin/nologin LucasDev

WORKDIR /app

COPY --from=builder \
    --chown=LucasDev:LucasDev \
    /app/auth-service \
    /app/auth-service

USER LucasDev

EXPOSE 8001

CMD ["/app/auth-service"]