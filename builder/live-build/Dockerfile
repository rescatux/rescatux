FROM amd64/debian:bookworm

RUN apt-get update && apt-get install -y \
    build-essential \
    devscripts \
    debhelper \
    git

WORKDIR /build

COPY external/live-build ./live-build

WORKDIR /build/live-build

RUN dpkg-buildpackage -us -uc

# Export artifacts to mounted volume
CMD cp ../live-build_*.deb /out/
