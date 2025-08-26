FROM alpine:latest

RUN apk add --no-cache --update \
    bash \
    coreutils \
    jellyfin-ffmpeg \
    gawk \
    grep \
    sed

RUN ln -sf /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/local/bin/ffmpeg && \
    ln -sf /usr/lib/jellyfin-ffmpeg/ffprobe /usr/local/bin/ffprobe

COPY --chown=nobody:nobody --chmod=755 stream-sprout /usr/bin/stream-sprout

EXPOSE 1935
USER nobody
ENTRYPOINT [ "stream-sprout" ]
