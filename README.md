<div align="center">
<img src=".github/logo.png" alt="Stream Sprout" width="256" />

# Stream Sprout

**Restream a video source to multiple destinations such as Twitch, YouTube, and Owncast.**

**Made with 💝 for <img src=".github/tux.png" align="top" width="24" alt="Tux (Linux)"/> & <img src=".github/apple.png" align="top" width="24" alt="Apple (macOS)"/>**
</div>

<p align="center">
  &nbsp;<a href="https://wimpysworld.io/discord" target="_blank"><img alt="Discord" src="https://img.shields.io/discord/712850672223125565?style=for-the-badge&logo=discord&logoColor=%23ffffff&label=Discord&labelColor=%234253e8&color=%23e4e2e2"></a>&nbsp;
  &nbsp;<a href="https://fosstodon.org/@wimpy" target="_blank"><img alt="Mastodon" src="https://img.shields.io/badge/Mastodon-6468fa?style=for-the-badge&logo=mastodon&logoColor=%23ffffff"></a>&nbsp;
  &nbsp;<a href="https://twitter.com/m_wimpress" target="_blank"><img alt="Twitter" src="https://img.shields.io/badge/Twitter-303030?style=for-the-badge&logo=x&logoColor=%23ffffff"></a>&nbsp;
  &nbsp;<a href="https://linkedin.com/in/martinwimpress" target="_blank"><img alt="LinkedIn" src="https://img.shields.io/badge/LinkedIn-1667be?style=for-the-badge&logo=linkedin&logoColor=%23ffffff"></a>&nbsp;
</p>

# Introduction

Stream Sprout 🌱 is a simple, self-contained, and easy-to-use solution for streaming to multiple destinations such as Twitch, YouTube, and [Owncast](https://owncast.online/) 📡
It uses [FFmpeg](https://ffmpeg.org/) to receive the video stream from OBS Studio (or anything that can publish a RTMP stream) and then restream it to multiple destinations; providing similar functionality as services like Restream.io and Livepush.io but without the need to pay 💸 for a third-party service or run something like nginx with the [RTMP module](https://github.com/arut/nginx-rtmp-module).

Stream Sprout is designed to be run on the same machine as your [OBS Studio](https://obsproject.com/) instance (but can be run remotely), is configured with a simple YAML file and can be executed by regular users without the need for root privileges.

There is no transcoding or processing of the video stream 🎞️
The stream is received and then restreamed to the destinations you configure without modification.
Optionally you can also archive the stream to disk 💾

While the restreaming process is lightweight, **your bandwidth requirements will increase with each destination you add.**
Ensure you have sufficient bandwidth to support the number of destinations you intend to stream to ⤴️

Stream Sprout is developed on Linux 🐧 and should work on macOS 🍏 or any other platform that supports `bash`, `ffmpeg` and `yq` 👍️

## Get Started

- [Install](#installation) Stream Sprout
- [Configure](#configuration) Stream Sprout
- [Configure](#configure-obs-studio) OBS Studio
- Start `stream-sprout`
- Click the *Start Streaming* button in OBS Studio

## Installation

### Debian

`yq` is available in bullseye-backports, bookworm, trixie and newer.

- Download the Stream Sprout .deb package from the [releases page]()
- Install it with `apt-get install ./stream-sprout_0.1.0-1_all.deb`.

### macOS

Install the Stream Sprout requirements using `brew`:

```shell
brew install bash ffmpeg procps yq
```

Now clone the project:

```shell
git clone https://github.com/wimpysworld/stream-sprout.git
cd stream-sprout
```

### Nix & NixOS

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/wimpysworld/stream-sprout/badge)](https://flakehub.com/flake/wimpysworld/stream-sprout)

Stable releases of Stream Sprout are published to FlakeHub for Nix users. See the flake on FlakeHub for more details:

- <https://flakehub.com/flake/wimpysworld/stream-sprout>

### Ubuntu 24.04 and newer

`yq` is available in Ubuntu 24.04 and newer.

- Download the Stream Sprout .deb package from the [releases page]()
- Install it with `apt-get install ./stream-sprout_0.1.0-1_all.deb`.

For Ubuntu versions earlier than 24.04 you can [install Stream Sprout from source](#from-source).

### From source

You need to have [FFmpeg](https://ffmpeg.org/) and [yq](https://github.com/kislyuk/yq) installed on your system.

```bash
git clone https://github.com/wimpysworld/stream-sprout.git
cd stream-sprout
```

## Configure Stream Sprout

Copy the [example Stream Sprout configuration](https://github.com/wimpysworld/stream-sprout/blob/main/stream-sprout.yaml.example) and edit it to suit your needs.
Stream Sprout will look for a configuration file in the following locations, in this order:
- Current working directory `./stream-sprout.yaml`
- XDG configuration directory `$XDG_CONFIG_HOME/stream-sprout.yaml` (*Linux*) or `~/.config/stream-sprout.yaml` (*macOS*)
- `/etc/stream-sprout.yaml`

### Server

The `server:` section is used to configure the RTMP server that Stream Sprout will listen on.
If `archive_stream:` is `true` Stream Sprout will archive the stream to disk in the directory specified by `archive_path:`.

### Services

`services:` are arbitrarily named.
Just create an entry for each RTMP destination you want to stream to.
The example configuration includes example entries for Trovo, Twitch, and YouTube.

```yaml
services:
  my-rtmp-destination:
    enabled: true
    rtmp_server: "rtmp://rtmp.example.com/live/"
    key: "my_super_secret_stream_key"
```

### Trovo

Here's an example configuration for Trovo.

```yaml
services:
  trovo:
    enabled: false
    rtmp_server: "rtmp://livepush.trovo.live/live/"
    key: "<your_stream_key>"
```

### Twitch

Here's an example configuration for Twitch.

```yaml
services:
  twitch:
    enabled: true
    rtmp_server: "rtmp://live.twitch.tv/app/"
    key: "<your_stream_key>"
```

#### Ingest servers

The example configuration uses the primary Twitch ingest server, which is `rtmp://live.twitch.tv/app/`.
If you want to optimise your stream quality, you can use a server closer to your location.
A short list of recommended servers based on your location is available from [Recommended Ingest Endpoints For You](https://help.twitch.tv/s/twitch-ingest-recommendation).

You can find a complete list of Twitch ingest servers from <https://twitchstatus.com/>.

#### Testing

If you want to test streaming to Twitch without going live, you can use the `?bandwidthtest=true` query parameter.

Add `?bandwidthtest=true` to the end of your Twitch stream key, this will enable bandwidth testing, which you can monitor at <https://inspector.twitch.tv/>, and the stream will not go live on your channel.

### YouTube

Here's an example configuration for YouTube.

```yaml
services:
  youtube:
    enabled: true
    rtmp_server: "rtmp://a.rtmp.youtube.com/live2/"
    key: "<your_stream_key>"
```

## Configure OBS Studio

- Open OBS Studio
- Go to `Settings` > `Stream`
- Select `Custom` from the `Service` dropdown
- Copy the server `url:` from your Stream Sprout configuration to the `Server` field:
  - `rtmp://127.0.0.1:1935` (*default*)

## Limitations

- Stream Sprout does not support secure RTMP (RTMPS) at this time.
- Each destination you add will increase your bandwidth requirements.

## References

These are some of the references used to create this project:

 - https://trac.ffmpeg.org/wiki/EncodingForStreamingSites
 - https://ffmpeg.org/ffmpeg-protocols.html#rtmp
 - https://ffmpeg.org/ffmpeg-formats.html#flv
 - https://ffmpeg.org/ffmpeg-formats.html#tee-1
 - https://obsproject.com/forum/resources/obs-studio-stream-to-multiple-platforms-or-channels-at-once.932/
 - https://stackoverflow.com/questions/16658873/how-to-minimize-the-delay-in-a-live-streaming-with-ffmpeg
