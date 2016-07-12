FROM lsiobase/alpine
MAINTAINER sparklyballs

# package version
ARG ZNC_VER="master"

# environment settings
ARG ZNC_SRC="/tmp/znc"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	cyrus-sasl-dev \
	g++ \
	gcc \
	git \
	icu-dev \
	make \
	openssl-dev \
	perl-dev \
	python3-dev \
	swig \
	tcl-dev && \

# fetch source code
 git clone \
 https://github.com/znc/znc.git -b \
	"${ZNC_VER}" --recursive "${ZNC_SRC}" && \

# configure and compile znc
 cd "${ZNC_SRC}" && \
 git clean -xdf && \
 ./autogen.sh && \
 ./configure \
	--disable-ipv6 \
	--enable-cyrus \
	--enable-perl \
	--enable-python \
	--enable-swig \
	--enable-tcl && \
 make && \
 make install && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# install runtime packages
RUN \
 apk add --no-cache \
	icu-libs

# add local files
COPY /root /

# ports and volumes
EXPOSE 6501
VOLUME /config
