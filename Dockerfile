FROM lsiobase/alpine:3.8 as buildstage
############## build stage ##############

# package version
ARG ZNC_VER="latest"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache \
	autoconf \
	automake \
	c-ares-dev \
	curl \
	cyrus-sasl-dev \
	g++ \
	gcc \
	gettext-dev \
	git \
	icu-dev \
	make \
	openssl-dev \
	perl-dev \
	python3-dev \
	swig \
	tar \
	tcl-dev

RUN \
 echo "**** compile znc ****" && \
 mkdir -p \
	/tmp/znc && \
 curl -o \
 /tmp/znc-src.tar.gz -L \
	"http://znc.in/nightly/znc-${ZNC_VER}.tar.gz" && \
 tar xf \
 /tmp/znc-src.tar.gz -C \
	/tmp/znc --strip-components=1 && \
 curl -o \
 /tmp/playback.tar.gz -L \
	https://github.com/jpnurmi/znc-playback/archive/master.tar.gz && \
 tar xf \
 /tmp/playback.tar.gz -C \
	/tmp/znc/modules --strip-components=1 && \
 cd /tmp/znc && \
 export CFLAGS="$CFLAGS -D_GNU_SOURCE" && \
 ./configure \
	--build=$CBUILD \
	--enable-cyrus \
	--enable-perl \
	--enable-python \
	--enable-swig \
	--enable-tcl \
	--host=$CHOST \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/etc && \
 make && \
 make  DESTDIR=/tmp/znc install

RUN \
 echo "**** determine runtime packages ****" && \
 scanelf --needed --nobanner /tmp/znc/usr/bin/znc \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
	>> /tmp/znc/packages
############## runtime stage ##############

FROM lsiobase/alpine:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# copy files from build stage
COPY --from=buildstage /tmp/znc/usr/ /usr/
COPY --from=buildstage /tmp/znc/packages /packages

RUN \
 echo "**** install runtime packages ****" && \
 RUNTIME_PACKAGES=$(echo $(cat /packages)) && \
 apk add --no-cache \
	ca-certificates \
	${RUNTIME_PACKAGES}

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 6501
VOLUME /config
