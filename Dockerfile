# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.19 as buildstage
############## build stage ##############

# package version
ARG ZNC_RELEASE

ENV MAKEFLAGS="-j4"

RUN \
  echo "**** install build packages ****" && \
  apk add -U --update --no-cache \
    argon2-dev \
    autoconf \
    automake \
    boost-dev\
    build-base \
    c-ares-dev \
    cyrus-sasl-dev \
    gettext-dev \
    git \
    icu-dev \
    openssl-dev \
    perl-dev \
    python3-dev \
    swig \
    tar \
    tcl-dev && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir pip setuptools && \
  pip install -U --no-cache-dir cmake

RUN \
  echo "**** compile znc ****" && \
  if [ -z ${ZNC_RELEASE+x} ]; then \
    ZNC_RELEASE=$(curl -s https://api.github.com/repos/znc/znc/tags \
    | jq -r 'first(.[] | select(.name | test("-rc|-beta|-alpha") | not)) | .name'); \
  fi && \
  mkdir -p \
    /tmp/znc && \
  git clone --branch "${ZNC_RELEASE}" --depth 1 \
    --recurse-submodules \
    https://github.com/znc/znc.git \
    /tmp/znc && \
  curl -o \
    /tmp/playback.tar.gz -L \
    https://github.com/jpnurmi/znc-playback/archive/master.tar.gz && \
  tar xf \
    /tmp/playback.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  curl -o \
    /tmp/znc-push.tar.gz -L \
    https://github.com/jreese/znc-push/archive/master.tar.gz && \
  tar xf \
    /tmp/znc-push.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  curl -o \
    /tmp/znc-clientbuffer.tar.gz -L \
    https://github.com/CyberShadow/znc-clientbuffer/archive/master.tar.gz && \
  tar xf \
    /tmp/znc-clientbuffer.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  curl -o \
    /tmp/znc-palaver.tar.gz -L \
    https://github.com/cocodelabs/znc-palaver/archive/master.tar.gz && \
  tar xf \
    /tmp/znc-palaver.tar.gz -C \
    /tmp/znc/modules --strip-components=1 && \
  cd /tmp/znc && \
  mkdir -p build && \
  cd build && \
  cmake .. \
    -DWANT_PYTHON=yes \
    -DWANT_PERL=yes \
    -DWANT_TCL=yes && \
  make && \
  make DESTDIR=/tmp/znc install

RUN \
  echo "**** determine runtime packages ****" && \
  scanelf --needed --nobanner /tmp/znc/usr/local/bin/znc \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u \
    | xargs -r apk info --installed \
    | sort -u \
    >> /tmp/znc/packages
############## runtime stage ##############

FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="notaptalca"

# copy files from build stage
COPY --from=buildstage /tmp/znc/usr/ /usr/
COPY --from=buildstage /tmp/znc/packages /packages

RUN \
  echo "**** install runtime packages ****" && \
  RUNTIME_PACKAGES=$(echo $(cat /packages)) && \
  apk add -U --update --no-cache \
    ${RUNTIME_PACKAGES}

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6501
VOLUME /config
