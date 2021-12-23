
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

RUN mkdir -p /dest /dest/var/run /dest/var/db /dest/etc \
  && cp /dist/usr/local/sbin/dhcpd /dest \
  && cp /dist/usr/local/etc/dhcpd.conf.example /dest/etc/dhcpd.conf \
  && touch /dest/var/db/dhcpd.leases \
  && setcap 'cap_net_raw,cap_net_bind_service=+eip' /dest/dhcpd


FROM scratch

VOLUME /var

COPY --from=builder --chown=1000:1000 /dest /

USER 1000:1000

ENTRYPOINT ["/dhcpd"]

CMD ["-d"]
