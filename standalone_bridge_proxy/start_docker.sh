docker run \
  -p 443:443 \
  -v ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
  -v ./certwprivkey.pem:/usr/local/etc/haproxy/certwprivkey.pem \
  -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  -e HAPROXY_VERSION=2.9.7 \
  -e HAPROXY_URL=https://www.haproxy.org/download/2.9/src/haproxy-2.9.7.tar.gz \
  -e HAPROXY_SHA256=d1a0a56f008a8d2f007bc0c37df6b2952520d1f4dde33b8d3802710e5158c131 \
  -it \
  --hostname zkevm-bridge-proxy-001-no-bs \
  --name manual-proxy \
  haproxy:2.9.7 \
  haproxy -f /usr/local/etc/haproxy/haproxy.cfg