FROM ubuntu:20.04

LABEL maintainer="Jeffrey Phillips Freeman the@jeffreyfreeman.me"

# Install needed tools
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get dist-upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
      iproute2 \
      net-tools \
      dnsutils \
      iputils-ping \
      nano \
      procps \
      htop \
      jq \
      curl \
      wget \
      pastebinit \
      bash \
      telnet \
      sed \
      rsync \
      pv \
      gawk && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# Use sprunge like wgetpaste
COPY sprunge /usr/bin/
COPY cp-progress /usr/bin
RUN ln -s /usr/bin/sprunge /usr/bin/wgetpaste

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY 30-add-host-ip-entry.sh /docker-entrypoint.d/30-add-host-ip-entry.sh
COPY docker-run.sh /docker-run.sh
RUN mkdir -p /docker-run.d

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/docker-run.sh" ]

