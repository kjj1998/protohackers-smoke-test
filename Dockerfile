# syntax=docker/dockerfile:1

FROM golang:1.25.1 AS build-stage

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY *.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /smoke-test-server

FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /smoke-test-server /smoke-test-server

EXPOSE 8090

USER nonroot:nonroot

ENTRYPOINT ["/smoke-test-server"]