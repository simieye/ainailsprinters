# AI NAILS APP - Docker 构建环境
# 用于 CI/CD 自动化构建

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    openjdk-17-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# 安装 Flutter
ENV FLUTTER_VERSION=3.22.0
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && flutter config --no-analytics \
    && flutter precache

# 工作目录
WORKDIR /app

# 预下载 Dart SDK
RUN dart --version

CMD ["flutter", "--version"]
