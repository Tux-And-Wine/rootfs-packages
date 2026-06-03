FROM ubuntu:24.04

ARG http_proxy
ARG https_proxy
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG no_proxy
ARG NO_PROXY

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        autopoint \
        bash \
        binutils-aarch64-linux-gnu \
        bison \
        bzip2 \
        ca-certificates \
        cmake \
        curl \
        file \
        flex \
        g++ \
        g++-aarch64-linux-gnu \
        gawk \
        gcc \
        gcc-aarch64-linux-gnu \
        gettext \
        git \
        gperf \
        gzip \
        libtool \
        libwayland-bin \
        libwayland-dev \
        make \
        meson \
        ninja-build \
        patch \
        perl \
        pkg-config \
        python3 \
        python3-packaging \
        rsync \
        tar \
        texinfo \
        unzip \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN printf '%s\n' \
        '#!/bin/sh' \
        'exec pkg-config "$@"' \
        > /usr/local/bin/aarch64-linux-gnu-pkg-config \
    && chmod +x /usr/local/bin/aarch64-linux-gnu-pkg-config

WORKDIR /work/repo
CMD ["/bin/bash"]
