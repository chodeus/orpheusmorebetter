FROM python:3.14.3-alpine AS builder

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

FROM python:3.14.3-alpine AS flac-builder

ARG FLAC_VERSION=1.5.0
ARG FLAC_SHA256=f2c1c76592a82ffff8413ba3c4a1299b6c7ab06c734dee03fd88630485c2b920

RUN apk add --no-cache build-base libogg-dev xz \
    && wget -q "https://downloads.xiph.org/releases/flac/flac-${FLAC_VERSION}.tar.xz" \
    && echo "${FLAC_SHA256}  flac-${FLAC_VERSION}.tar.xz" | sha256sum -c - \
    && tar xf flac-${FLAC_VERSION}.tar.xz \
    && cd flac-${FLAC_VERSION} \
    && ./configure --prefix=/usr --disable-static --disable-thorough-tests \
    && make -j$(nproc) \
    && make install DESTDIR=/artifacts

FROM python:3.14.3-alpine AS sox-builder

ARG SOX_NG_VERSION=14.7.1
ARG SOX_NG_SHA256=255872ac397213d330f4633871b697d70e86242dff95d66016555a45ef1c58a1

COPY --from=flac-builder /artifacts/usr/ /usr/

RUN apk add --no-cache build-base libogg-dev pkgconf \
    && wget -q "https://codeberg.org/sox_ng/sox_ng/releases/download/sox_ng-${SOX_NG_VERSION}/sox_ng-${SOX_NG_VERSION}.tar.gz" \
    && echo "${SOX_NG_SHA256}  sox_ng-${SOX_NG_VERSION}.tar.gz" | sha256sum -c - \
    && tar xzf sox_ng-${SOX_NG_VERSION}.tar.gz \
    && cd sox_ng-${SOX_NG_VERSION} \
    && ./configure --prefix=/usr --enable-replace --disable-static --disable-openmp --without-sndfile --without-libltdl \
    && make -j$(nproc) \
    && make install DESTDIR=/artifacts

FROM python:3.14.3-alpine

COPY --from=flac-builder /artifacts/usr/bin/ /usr/bin/
COPY --from=flac-builder /artifacts/usr/lib/ /usr/lib/
COPY --from=sox-builder /artifacts/usr/bin/ /usr/bin/
COPY --from=sox-builder /artifacts/usr/lib/ /usr/lib/

RUN apk add --no-cache \
    mktorrent \
    lame \
    libogg \
    libxml2 \
    libxslt \
    openssl \
    ca-certificates \
    shadow \
    su-exec \
    tini \
    tzdata \
    && rm -rf /tmp/* /usr/share/man /usr/share/doc

WORKDIR /app

COPY --from=builder /wheels /tmp/wheels
RUN pip install --no-cache-dir --no-compile /tmp/wheels/* \
    && pip uninstall -y setuptools wheel pip 2>/dev/null || true \
    && rm -rf /tmp/wheels \
    && rm -rf /root/.cache/pip

COPY orpheusmorebetter start.sh _version.py ./
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
      org.opencontainers.image.base.name="python:3.13.2-alpine"

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
