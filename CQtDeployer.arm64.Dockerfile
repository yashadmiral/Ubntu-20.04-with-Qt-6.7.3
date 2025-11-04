# Build CQtDeployer on top of the prebuilt Qt 6.7.3 ARM64 image.
# The workflow passes BASE_IMAGE=ghcr.io/<OWNER>/qt-6.7.3-arm64:latest

ARG BASE_IMAGE
ARG QT_PREFIX=/opt/Qt/6.7.3
ARG CQTDEPLOYER_REF=main

FROM ${BASE_IMAGE} AS build
ARG DEBIAN_FRONTEND=noninteractive
ARG QT_PREFIX
ARG CQTDEPLOYER_REF

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git cmake ninja-build pkg-config ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV CMAKE_PREFIX_PATH=${QT_PREFIX}
WORKDIR /src

RUN git clone --depth 1 --branch ${CQTDEPLOYER_REF} https://github.com/QuasarApp/CQtDeployer.git CQtDeployer \
 && cd CQtDeployer && git submodule update --init --recursive

WORKDIR /src/CQtDeployer

RUN cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} \
      -DCQT_DEPLOYER_TESTS=0 \
 && cmake --build build --parallel \
 && cmake --install build --prefix /usr/local

# Runtime stage uses the same Qt image so required Qt libs are present.
ARG BASE_IMAGE
FROM ${BASE_IMAGE} AS runtime
COPY --from=build /usr/local /usr/local

RUN /usr/local/bin/cqtdeployer --version || true

ENTRYPOINT ["/usr/local/bin/cqtdeployer"]
CMD ["--help"]