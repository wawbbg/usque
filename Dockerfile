FROM golang:1.25.5-alpine AS builder

WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN go build -o usque -ldflags="-s -w" .

# scratch won't be enough, because we need a cert store
FROM alpine:latest

# Keep ca-certificates up to date for TLS connections
RUN apk --no-cache add ca-certificates && update-ca-certificates

# Create a non-root user for running the binary
RUN adduser -D -H -s /sbin/nologin usque

WORKDIR /app

COPY --from=builder /app/usque /bin/usque

USER usque

ENTRYPOINT ["/bin/usque"]
