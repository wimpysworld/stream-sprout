# Configuration

Stream Sprout reads a single YAML file that defines the local RTMP listener under `server:` and every broadcast target under `services:`. Start from [`stream-sprout.yaml.example`](https://github.com/wimpysworld/stream-sprout/blob/main/stream-sprout.yaml.example) and edit the values for your platforms.

## Configuration search order

Pass `--config <path>` to load a specific file:

```shell
stream-sprout --config /path/to/stream-sprout.yaml
```

When you omit `--config`, Stream Sprout checks these paths in order and uses the first file that exists:

1. `./stream-sprout.yaml` in the current working directory.
2. `$XDG_CONFIG_HOME/stream-sprout.yaml` (or `~/.config/stream-sprout.yaml` when `XDG_CONFIG_HOME` is unset, including macOS).
3. `/etc/stream-sprout.yaml`.

### YAML format rules

Stream Sprout parses YAML with `sed` and `awk`. Follow these formatting rules so every key parses cleanly:

- Use two spaces per indentation level.
- Use letters, numbers, and underscores (`[a-zA-Z0-9_]`) for keys and service names. Do not use hyphens in service names.
- Stream Sprout expands `~` to `$HOME` in values such as `archive_path`.
- Stream Sprout reloads the YAML file automatically after each broadcast ends, so edits apply on the next broadcast without a restart.

## Server options

The `server:` block configures the local RTMP server that receives your stream from OBS Studio or another RTMP encoder.

```yaml
server:
  ip: 127.0.0.1
  port: 1935
  app: sprout
  key: create_your_key_with_uuidgen
  archive_stream: false
  archive_path: ~/Streams
```

| Key | Default | Valid values | Description |
| --- | --- | --- | --- |
| `ip` | `127.0.0.1` | IPv4 address | Address that FFmpeg listens on. Invalid values fall back to `127.0.0.1`. Use `0.0.0.0` to listen on every network interface. |
| `port` | `1935` | `1024` to `65535` | TCP port for the incoming RTMP stream. Invalid values fall back to `1935`. |
| `app` | `sprout` | Non-empty string | RTMP application name in the ingest URL. Empty values fall back to `sprout`. |
| `key` | *(empty)* | String | Stream key appended to the ingest URL. Run `uuidgen` to generate one. |
| `archive_stream` | `false` | `true`, `1`, `false`, `0` | Enable or disable local Matroska (`.mkv`) recording during broadcasts. |
| `archive_path` | *(empty)* | Directory path | Directory for saved recordings. `~` expands to `$HOME`. |

Stream Sprout builds the ingest address as `rtmp://<ip>:<port>/<app>` (or `rtmp://<ip>:<port>/<app>/<key>` when `key` is set). The deprecated `server.url` key causes Stream Sprout to exit with an error. Configure `ip` and `port` instead.

> [!WARNING]
> FFmpeg's RTMP listener accepts any incoming stream on `server.port` regardless of `app` or `key`. Read [Security and limitations](Security-and-Limitations) before you change `ip` from `127.0.0.1`.

## Stream archiving

When `archive_stream` is `true` (or `1`), Stream Sprout adds a local Matroska (`.mkv`) output to FFmpeg's tee muxer. Recording copies the incoming stream directly to disk with no transcoding and no extra upload bandwidth.

- Stream Sprout creates `archive_path` if the directory does not exist.
- When `archive_path` is empty, Stream Sprout writes to the parent directory of the current working directory.
- During a broadcast, FFmpeg writes to a temporary file named `stream-temp-<timestamp>.mkv`.
- When the broadcast stops or you press <kbd>Ctrl</kbd>+<kbd>C</kbd>, Stream Sprout renames the file to `stream-sprout-YYYYMMDD_HHMMSS.mkv`.

## Services schema

Add one entry under `services:` for each destination. Name each entry with letters, digits, and underscores (`[a-zA-Z0-9_]`).

```yaml
services:
  my_destination:
    enabled: true
    rtmp_server: "rtmp://rtmp.example.com/live/"
    key: "my_super_secret_stream_key"
```

| Key | Description |
| --- | --- |
| `enabled` | Set to `true` (case-insensitive) or `1` to stream to this destination. Any other value skips it. |
| `rtmp_server` | Destination ingest URL. Must start with `rtmp://` or `rtmps://`. |
| `key` | Platform stream key appended to `rtmp_server`. |

Stream Sprout concatenates `<rtmp_server>/<key>` and passes each enabled service to FFmpeg's `tee` muxer as `[f=flv:onfail=ignore]<uri>`. When one destination disconnects or rejects the stream, FFmpeg continues streaming to the remaining destinations.

## Twitch

```yaml
services:
  twitch:
    enabled: true
    rtmp_server: "rtmp://live.twitch.tv/app/"
    key: "your_twitch_stream_key"
```

### Twitch ingest servers

`rtmp://live.twitch.tv/app/` is the primary Twitch ingest endpoint. To lower latency, replace it with an ingest server near your location:

- Check [Recommended Ingest Endpoints For You](https://help.twitch.tv/s/twitch-ingest-recommendation) for endpoints close to you.
- Browse the full server list on [Twitch Status](https://twitchstatus.com/).

### Testing with `?bandwidthtest=true`

To test your Twitch stream without going live on your channel, append `?bandwidthtest=true` to the end of your Twitch `key`:

```yaml
services:
  twitch:
    enabled: true
    rtmp_server: "rtmp://live.twitch.tv/app/"
    key: "your_twitch_stream_key?bandwidthtest=true"
```

Monitor connection health and bitrate in [Twitch Inspector](https://inspector.twitch.tv/), then remove `?bandwidthtest=true` before your real broadcast.

## YouTube

```yaml
services:
  youtube:
    enabled: true
    rtmp_server: "rtmp://a.rtmp.youtube.com/live2/"
    key: "your_youtube_stream_key"
```

## Owncast, PeerTube, and RTMPS targets

Stream Sprout works with self-hosted platforms such as [Owncast](https://owncast.online/) and [PeerTube](https://joinpeertube.org/), and accepts both `rtmp://` and `rtmps://` destination URLs in `rtmp_server`.

```yaml
services:
  owncast:
    enabled: true
    rtmp_server: "rtmp://stream.example.org/live/"
    key: "your_owncast_stream_key"
  peertube:
    enabled: true
    rtmp_server: "rtmp://video.example.org:1935/live/"
    key: "your_peertube_stream_key"
  youtube_tls:
    enabled: false
    rtmp_server: "rtmps://a.rtmps.youtube.com/live2/"
    key: "your_youtube_stream_key"
```

### RTMPS requirements

- Outgoing `rtmps://` destinations require an `ffmpeg` build with TLS support (such as GnuTLS or OpenSSL). Check support with `ffmpeg -protocols | grep rtmps`.
- The local ingest listener under `server:` uses plain `rtmp://` only. Use a VPN or SSH tunnel when OBS Studio connects across an untrusted network.
