# This is for an image based on debian

FROM rust:1-bullseye AS builder

ENV USER=root
WORKDIR /code
RUN cargo init

# Fetch all the dependencies without loading the code to have an independant layer
COPY Cargo.lock Cargo.toml /code/
RUN mkdir -p /code/.cargo
RUN cargo vendor >> /code/.cargo/config.toml

# Copy the source code and compile
COPY src /code/src
RUN cargo build --release --offline

FROM debian:bullseye

COPY --from=builder /code/target/release/mastodon-twitter-sync /usr/bin/mastodon-twitter-sync

# Use a separate workdir so that users can have a Docker volume with their
# settings file. Cache files will also be written here.
WORKDIR /data

ENTRYPOINT ["/usr/bin/mastodon-twitter-sync"]