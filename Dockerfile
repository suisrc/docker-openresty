FROM alpine:3.18
ARG BUILDDATE
LABEL buildDate=$BUILDDATE
RUN apk --no-cache upgrade && \
    apk add -U --no-cache bash iptables ip6tables nftables
ADD [ "entry", "p2p", "/usr/bin/" ]
CMD ["entry"]
