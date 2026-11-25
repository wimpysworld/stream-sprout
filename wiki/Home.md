# Stream Sprout documentation

Stream Sprout is a Bash and [FFmpeg](https://ffmpeg.org/) tool that receives one Real-Time Messaging Protocol (RTMP) stream from [OBS Studio](https://obsproject.com/) and forwards it to multiple destinations without transcoding.

[Install Stream Sprout](https://github.com/wimpysworld/stream-sprout/blob/main/README.md#install), create `stream-sprout.yaml` with the [Configuration guide](Configuration), and connect your encoder with the [OBS Studio guide](OBS-Studio). Read [Security and limitations](Security-and-Limitations) before you expose the RTMP port outside `127.0.0.1`.

## Documentation pages

| Page | Use it to |
| --- | --- |
| [Configuration](Configuration) | Set config search paths, `server:` options, local archiving, and destination services (Twitch, YouTube, Owncast, PeerTube, and RTMPS). |
| [OBS Studio](OBS-Studio) | Configure OBS Studio for local or remote Stream Sprout hosts. |
| [Security and limitations](Security-and-Limitations) | Understand FFmpeg's RTMP key caveat, harden remote deployments, and plan upload bandwidth. |
| [References](References) | Find upstream FFmpeg, OBS Studio, and container documentation, and collect `stream-sprout --info` output for bug reports. |

## Quick workflow

1. Copy [`stream-sprout.yaml.example`](https://github.com/wimpysworld/stream-sprout/blob/main/stream-sprout.yaml.example) to `stream-sprout.yaml` and add your stream keys.
2. Run `stream-sprout` in a terminal or container.
3. Click **Start Streaming** in OBS Studio to broadcast to every enabled destination.
4. Click **Stop Streaming** in OBS Studio when the broadcast ends, then press <kbd>Ctrl</kbd>+<kbd>C</kbd> to exit `stream-sprout`.
