FROM python:3.13-alpine AS builder

RUN apk add --no-cache \
    gcc \
    musl-dev \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    openssl-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /build

COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

COPY setup.py pyproject.toml _version.py ./
COPY models/ ./models/
COPY services/ ./services/
COPY orpheusmorebetter ./

RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels .

FROM python:3.13-alpine

RUN apk add --no-cache \
    mktorrent \
    flac \
    lame \
    sox \
    libxml2 \
    libxslt \
    openssl \
    ca-certificates \
    shadow \
    su-exec \
    tini \
    tzdata \
    && rm -rf /var/cache/apk/* /tmp/*

WORKDIR /app

COPY --from=builder /wheels /tmp/wheels
RUN pip install --no-cache-dir --no-compile /tmp/wheels/* \
    && rm -rf /tmp/wheels \
    && rm -rf /root/.cache/pip

COPY orpheusmorebetter start.sh ./
COPY models/ ./models/
COPY services/ ./services/

RUN chmod +x /app/orpheusmorebetter /app/start.sh \
    && mkdir -p /config/.orpheusmorebetter

ARG VERSION=dev
ARG GIT_BRANCH=main
ARG BUILD_DATE
ARG VCS_REF

RUN echo "v${VERSION}" > /app/version.txt \
    && echo "${GIT_BRANCH}" > /app/branch.txt

LABEL org.opencontainers.image.title="OrpheusMoreBetter" \
      org.opencontainers.image.description="Automatic transcode helper for Orpheus Network" \
      org.opencontainers.image.authors="CHODEUS" \
      org.opencontainers.image.url="https://github.com/CHODEUS/orpheusmorebetter" \
      org.opencontainers.image.source="https://github.com/CHODEUS/orpheusmorebetter" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.base.name="python:3.13-alpine"

ENV PUID=99 \
    PGID=100 \
    UMASK=002 \
    HOME=/config \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

VOLUME ["/config"]

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/start.sh"]
