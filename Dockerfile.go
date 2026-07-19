# =============================================================================
# Shared Go Dockerfile for all Go services
# Usage: docker build --build-arg SERVICE=api-gateway -f Dockerfile.go -t pulsegrid-go .
# =============================================================================

# Build stage
FROM golang:1.22-alpine AS builder

ARG SERVICE=api-gateway
ARG CGO_ENABLED=0
ARG GOOS=linux
ARG GOARCH=amd64

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Copy go.mod and go.sum for each service
COPY apps/${SERVICE}/go.mod ./go.mod
# If go.sum exists, copy it (optional, won't fail if missing)
COPY apps/${SERVICE}/go.sum* ./go.sum

# Download dependencies
RUN go mod download

# Copy source code
COPY apps/${SERVICE}/ ./

# Build the binary
RUN CGO_ENABLED=${CGO_ENABLED} GOOS=${GOOS} GOARCH=${GOARCH} \
    go build -ldflags="-w -s" -o /app/server .

# Runtime stage
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata curl

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/server .

# Copy config files if they exist
COPY --from=builder /app/*.toml* ./config/

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

EXPOSE ${PORT:-8080}

ENTRYPOINT ["./server"]
