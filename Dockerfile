FROM golang as builder
ARG SVU_VERSION
ENV GOPATH=/tmp/go
RUN go install github.com/caarlos0/svu/v3@v${SVU_VERSION}

FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install --no-install-suggests --no-install-recommends --yes ca-certificates git openssl
COPY --from=builder /tmp/go/bin/svu /bin/svu
COPY entrypoint /bin/entrypoint
COPY askpass /bin/askpass
ENV GIT_ASKPASS=/bin/askpass
ENTRYPOINT ["/bin/entrypoint"]
