FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    build-essential \
    devscripts \
    debhelper \
    git \
    apt-utils

WORKDIR /build

COPY external/live-build ./live-build

WORKDIR /build/live-build

RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i 's/^# deb-src/deb-src/' /etc/apt/sources.list || true; \
    fi

RUN if [ -d /etc/apt/sources.list.d ]; then \
        find /etc/apt/sources.list.d -type f -name "*.sources" -exec \
        sed -i 's/^Types: deb$/Types: deb deb-src/; s/^Types: deb /Types: deb deb-src /' {} \; || true; \
    fi

RUN apt-get update && \
    apt-get build-dep -y .

RUN dpkg-buildpackage -us -uc

# Export artifacts to mounted volume
CMD cp ../live-build_*.deb /out/
