FROM i386/debian:12

ARG RESCATUX_BUILDER_UID
ARG RESCATUX_BUILDER_GID

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo '\
deb-src http://deb.debian.org/debian bookworm main\n\
deb-src http://security.debian.org/debian-security bookworm-security main\n\
deb-src http://deb.debian.org/debian bookworm-updates main\n\
' > /etc/apt/sources.list.d/debian-sources.list

RUN apt-get -y update && \
    apt-get -y install \
                       sudo \
                       git \
                       syslinux \
                       syslinux-utils \
                       policycoreutils \
                       coreutils \
                       selinux-utils \
                       selinux-policy-default

# TODO: Install our own live-build package if needed.
RUN apt-get -y install live-build

#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

RUN echo "rbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/rbuilder-sudo
RUN groupadd -g ${RESCATUX_BUILDER_GID} rbuilder
RUN useradd -u ${RESCATUX_BUILDER_UID} rbuilder -g rbuilder
ADD --chown=${RESCATUX_BUILDER_UID}:${RESCATUX_BUILDER_GID} . /rescatux-repo
RUN mkdir /rescatux-build
RUN chown ${RESCATUX_BUILDER_UID}:${RESCATUX_BUILDER_GID} /rescatux-build

USER rbuilder
RUN git clone /rescatux-repo /rescatux-build
WORKDIR /rescatux-build
