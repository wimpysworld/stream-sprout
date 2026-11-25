# References

Upstream documentation and resources used to build Stream Sprout, plus guidance on collecting system details for bug reports.

## Upstream references

### FFmpeg

- [Encoding for Streaming Sites (FFmpeg Wiki)](https://trac.ffmpeg.org/wiki/EncodingForStreamingSites) - Bitrate, keyframe interval, and codec guidelines for live streaming platforms.
- [RTMP Protocol Documentation (FFmpeg)](https://ffmpeg.org/ffmpeg-protocols.html#rtmp) - Options for FFmpeg's RTMP client and `-listen 1` server mode.
- [FLV Muxer Documentation (FFmpeg)](https://ffmpeg.org/ffmpeg-formats.html#flv) - FLV container options used for outgoing RTMP streams, including `no_duration_filesize`.
- [Tee Pseudo-Muxer Documentation (FFmpeg)](https://ffmpeg.org/ffmpeg-formats.html#tee-1) - Multi-output muxing, `-use_fifo 1`, and per-output `onfail=ignore` behaviour.
- [Minimising live streaming delay with FFmpeg (Stack Overflow)](https://stackoverflow.com/questions/16658873/how-to-minimize-the-delay-in-a-live-streaming-with-ffmpeg) - Low-latency flags such as `-fflags nobuffer`.

### OBS Studio

- [Stream to multiple platforms or channels at once (OBS Project Forums)](https://obsproject.com/forum/resources/obs-studio-stream-to-multiple-platforms-or-channels-at-once.932/) - Community guide on multi-destination workflows from OBS Studio.

### Containers

- [Running FFmpeg inside a Docker container (DEV Community)](https://dev.to/ajeetraina/run-ffmpeg-within-a-docker-container-a-step-by-step-guide-c0l) - Background on packaging FFmpeg in containers.
- [jrottenberg/ffmpeg (GitHub)](https://github.com/jrottenberg/ffmpeg) - Reference container builds for FFmpeg.

## Filing a bug report

Before opening an issue on [GitHub Issues](https://github.com/wimpysworld/stream-sprout/issues), run:

```shell
stream-sprout --info
```

Include the full output in your report. `--info` prints:

- Operating system name and version.
- Container status and runtime (`docker`, `lxc`, `podman`, or `snapd`) on Linux.
- Stream Sprout version.
- Installed `awk`, `bash`, and `ffmpeg` versions.

When a broadcast fails to start or drops a destination, attach the relevant lines from the FFmpeg log file printed at startup (for example `/tmp/stream-sprout.XXXXXX.log`).

> [!IMPORTANT]
> Remove all stream keys from your `stream-sprout.yaml` snippet and FFmpeg log excerpts before you post them in a public issue.
