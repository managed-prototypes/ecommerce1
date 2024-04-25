FROM rust:1.74-bullseye as builder

WORKDIR /usr/src/backend

COPY . .

# Note: 
# - protobuf-compiler is required for the Pulsar support
RUN apt-get update && apt-get install -y protobuf-compiler

RUN cargo install --path .

FROM debian:12.2-slim

# Note: 
# - ca-certificates solves an issue with some SSL certificates (when running HTTP requests to other servers)
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
RUN update-ca-certificates

COPY --from=builder /usr/local/cargo/bin/server /usr/local/bin/server

CMD ["server"]
