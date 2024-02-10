# Original credit: https://github.com/kylemanna/docker-openvpn
FROM alpine:3.19.1

LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

ARG OVPN_VERSION=2.6.8-r0

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update --no-cache \
    openvpn=${OVPN_VERSION} \
    iptables=1.8.10-r3 \
    bash=5.2.21-r0 \
    easy-rsa=3.1.7-r0 \
    openvpn-auth-pam=${OVPN_VERSION} \
    google-authenticator=1.09-r2\
    pamtester=0.1.2-r3 \
    libqrencode=4.1.1-r2 && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

COPY ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
COPY ./otp/openvpn /etc/pam.d/
