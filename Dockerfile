FROM golang as builder
ARG SVU_VERSION
RUN apt-get update \
 && apt-get install --no-install-suggests --no-install-recommends --yes ca-certificates git \
 && git clone --depth 1 --branch v${SVU_VERSION} https://github.com/caarlos0/svu \
 && cd svu \
 && CGO_ENABLED=0 go build -o /bin/svu .

FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install --no-install-suggests --no-install-recommends --yes git
COPY --from=builder /bin/svu /bin/svu
COPY entrypoint /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]
