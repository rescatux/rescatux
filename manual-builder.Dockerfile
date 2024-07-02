FROM i386/debian:12

ARG RESCATUX_BUILDER_UID
ARG RESCATUX_BUILDER_GID

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -qq update -y && \
    apt-get -qq install -y \
                       sudo \
                       git \
                       syslinux \
                       syslinux-utils \
                       policycoreutils \
                       coreutils \
                       selinux-utils \
                       selinux-policy-default

# TODO: Install our own live-build package if needed.
RUN apt-get -qq install -y live-build

RUN apt-get -qq install -y locales
RUN locale-gen en_US.UTF-8


RUN dpkg --add-architecture amd64

RUN apt-get -qq update -y

RUN echo "rbuilder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/rbuilder-sudo
RUN groupadd -g ${RESCATUX_BUILDER_GID} rbuilder
RUN useradd -u ${RESCATUX_BUILDER_UID} rbuilder -g rbuilder
ADD --chown=${RESCATUX_BUILDER_UID}:${RESCATUX_BUILDER_GID} . /rescatux-repo
RUN mkdir /rescatux-build
RUN chown ${RESCATUX_BUILDER_UID}:${RESCATUX_BUILDER_GID} /rescatux-build

USER rbuilder
RUN git clone /rescatux-repo /rescatux-build

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /rescatux-build
