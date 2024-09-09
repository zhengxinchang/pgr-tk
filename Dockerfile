FROM ubuntu:22.04
RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN mkdir -p /software/pgr-tk
COPY ./ /software/pgr-tk
RUN apt-get install -y build-essential git ssh curl clang-14 cmake libssl-dev libssl3 pkg-config libzstd-dev zstd
RUN mkdir -p /opt
ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
RUN RUSTUP_HOME=${RUSTUP_HOME} CARGO_HOME=${CARGO_HOME} bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
RUN . /opt/cargo/env && rustup default stable
RUN . /opt/cargo/env && cargo install --locked maturin
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
RUN . /opt/cargo/env && rustup toolchain list
RUN apt-get install -y zlib1g-dev zlib1g libdeflate-dev
RUN /opt/cargo/bin/rustup default stable
RUN cd /software/pgr-tk/ && /opt/cargo/bin/cargo build -p pgr-db --release
RUN cd /software/pgr-tk/ && /opt/cargo/bin/cargo build -p pgr-bin --release
RUN cd /software/pgr-tk/agc/ && make || true
RUN mkdir -p /software/bins/
RUN ls /software/pgr-tk/pgr-bin/
RUN ls /software/pgr-tk/target/
RUN ls /software/pgr-tk/target/release/
RUN cp /software/pgr-tk/target/release/pgr-* /software/bins/
RUN cp /software/pgr-tk/agc/agc /software/bins/