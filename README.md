# ISC DHCP Daemon Container

This repository builds a container image containing the [ISC's DHCP daemon](https://www.isc.org/dhcp/).

## Usage

The image is designed for a minimal footprint and attack surface. It only contains a single static
binary and the example configuration file (i.e. it is a 'distroless' image). By default, the image
runs as UID/GID 1000.

**⚠️ Important**: In order for the DHCP server to work you must grant the container superuser privileges
(not recommended) or add the `CAP_NET_BIND_SERVICE` and `CAP_NET_RAW` ambient capabilites.

## Tags

Builds are provided for the latest stable and Extended Supported Version (ESV). As well as their
corresponding Major, Major.Minor and Major.Minor.Patch versions.

* `latest`, `stable`
* `esv`

Builds are provided for the following architectures `linux/amd64,linux/arm64,linux/arm/v7`

## Example

This provides DHCP on the default docker network

Create a `dhcpd.conf` with the following contents:

```
shared-network test {
  subnet 172.0.0.0 netmask 255.0.0.0 {
    range 172.10.10.10 172.10.10.20;
  }
}
```

Now you can run the daemon with:

```
docker run -v $(pwd)/dhcpd.conf:/etc/dhcpd.conf:ro --name dhcp --cap-add CAP_NET_BIND_SERVICE --cap-add CAP_NET_RAW ghcr.io/heilerich/isc-dhcpd:stable 
```
