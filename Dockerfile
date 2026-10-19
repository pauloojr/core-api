FROM golang:1.23.2-alpine3.20 AS builder

WORKDIR /build

RUN apk add --no-cache ca-certificates git

COPY go.mod ./
COPY main.go ./

RUN go mod tidy && \
    go mod download && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o /build/core-api main.go

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /

COPY --from=builder /build/core-api /core-api

USER 65532:65532

EXPOSE 8080

ENTRYPOINT ["/core-api"]
