FROM python:3.13-alpine AS builder

RUN apk add --no-cache \
    gcc \
    musl-dev \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    openssl-dev

WORKDIR /build

COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

COPY setup.py pyproject.toml _version.py ./
COPY models/ ./models/
COPY services/ ./services/
COPY orpheusmorebetter ./

RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels .

# Build sox_ng from source as drop-in sox replacement
# Original SoX is unmaintained since 2015; sox_ng is the active fork
# https://codeberg.org/sox_ng/sox_ng
FROM python:3.13-alpine AS sox-builder

ARG SOX_NG_VERSION=14.7.1

RUN apk add --no-cache build-base flac-dev \
    && wget -q "https://codeberg.org/sox_ng/sox_ng/releases/download/sox_ng-${SOX_NG_VERSION}/sox_ng-${SOX_NG_VERSION}.tar.gz" \
    && tar xzf sox_ng-${SOX_NG_VERSION}.tar.gz \
    && cd sox_ng-${SOX_NG_VERSION} \
    && ./configure --enable-replace \
    && make -j$(nproc) \
    && make install DESTDIR=/sox-out

FROM python:3.13-alpine

# Install sox_ng (built as sox drop-in replacement)
COPY --from=sox-builder /sox-out/usr/local/ /usr/local/

RUN apk add --no-cache \
    mktorrent \
    flac \
    lame \
    libxml2 \
    libxslt \
    openssl \
    ca-certificates \
    shadow \
    su-exec \
    tini \
    tzdata \
    && rm -rf /tmp/*

WORKDIR /app

COPY --from=builder /wheels /tmp/wheels
RUN pip install --no-cache-dir --no-compile /tmp/wheels/* \
    && pip uninstall -y setuptools wheel pip 2>/dev/null || true \
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

ENTRYPOINT ["/sbin/tini", "--", "/app/start.sh"]
CMD []
