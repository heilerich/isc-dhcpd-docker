FROM ubuntu:latest AS builder

ARG DHCPD_VERSION

WORKDIR /build

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y curl build-essential libcap2-bin

RUN curl -s https://downloads.isc.org/isc/dhcp/${DHCPD_VERSION}/dhcp-${DHCPD_VERSION}.tar.gz | tar xvz -C /build 

RUN cd /build/* && \
  ./configure LDFLAGS="-static" && \
  mkdir /dist && \
  make && \
  make DESTDIR=/dist install

RUN mkdir -p /dest /dest/etc \
  && cp /dist/usr/local/sbin/dhcpd /dest \
  && cp /dist/usr/local/etc/dhcpd.conf.example /dest/etc/dhcpd.conf \
  && setcap 'cap_net_raw,cap_net_bind_service=+eip' /dest/dhcpd

ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz /s6.tar.gz
RUN tar xzf /s6.tar.gz -C /dest

ADD https://github.com/just-containers/socklog-overlay/releases/download/v3.1.2-0/socklog-overlay-amd64.tar.gz /socklog.tar.gz
RUN tar xzf /socklog.tar.gz -C /dest

COPY ./rootfs /dest

FROM scratch

VOLUME /var

COPY --from=builder --chown=root:root /dest /

ENV S6_READ_ONLY_ROOT=1

ENTRYPOINT ["/init"]
