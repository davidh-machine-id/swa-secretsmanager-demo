# Build stage
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o demo-app main.go

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates
RUN apk --no-cache add curl jq

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/demo-app .

# SWA agent socket will be mounted at runtime
# Typical usage: docker run -v /tmp/swa-agent:/tmp/swa-agent demo-app

ENTRYPOINT ["./demo-app"]