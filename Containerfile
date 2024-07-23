FROM ghcr.io/jrottenberg/ffmpeg:7-alpine
RUN apk update && apk add --no-cache bash coreutils gawk grep sed
COPY --chown=nobody:nobody --chmod=755 stream-sprout /usr/bin/stream-sprout
EXPOSE 1935
ENTRYPOINT [ "stream-sprout" ]
