# Security and limitations

Run Stream Sprout on the same computer as OBS Studio bound to `127.0.0.1` whenever possible. Read the security caveat and bandwidth limits below before you change `server.ip` or add destinations.

## FFmpeg does not enforce RTMP `app` or `key` paths

FFmpeg's built-in RTMP server (`-listen 1`) does not reject connections that use a wrong `app` name or `key`. Regardless of the `app` and `key` values in `stream-sprout.yaml`, FFmpeg accepts **any** incoming RTMP stream that connects to `server.port`.

When a client sends an unexpected stream key, FFmpeg logs a warning and still accepts the stream:

```text
[rtmp @ 0x2ca9be80] Unexpected stream STREAMBOMB, expecting c5b559b2-589d-4925-a28e-20d1954fd6c5
  Last message repeated 1 times
```

This is an upstream FFmpeg limitation:

- [Reddit r/ffmpeg discussion on enforcing RTMP stream keys](https://www.reddit.com/r/ffmpeg/comments/s4keuu/enforce_rtmp_stream_keys_and_strict_paths/)
- [FFmpeg Patchwork submission on strict RTMP path matching](https://patchwork.ffmpeg.org/project/ffmpeg/patch/20190925185708.70924-1-unique.will.martin@gmail.com/)

### Protect your configuration file

`stream-sprout.yaml` stores your destination stream keys in plain text. Restrict file permissions to your own user and never commit the file to Git:

```shell
chmod 600 stream-sprout.yaml
```

## Hardening remote deployments

Do not expose `server.port` (default `1935`) to the public internet. When Stream Sprout runs on another host, choose one of these methods:

1. **Use a private VPN (recommended for permanent hosts).** Connect the OBS Studio machine and the Stream Sprout host over a private VPN such as WireGuard or Tailscale, and set `server.ip` to the host's VPN address.
2. **Use an SSH tunnel (recommended for temporary or cloud hosts).** Keep `server.ip: 127.0.0.1` on the remote host so the RTMP port never listens on a public interface, then forward local port `1935` from the OBS Studio machine:

   ```shell
   ssh -N -L 1935:127.0.0.1:1935 user@remote-host
   ```

   Point OBS Studio at `rtmp://127.0.0.1:1935/sprout`.
3. **Restrict access with a host firewall.** When a VPN or SSH tunnel is not available, configure your firewall (for example `ufw` or `nftables`) so TCP port `1935` (or your custom `server.port`) accepts connections only from the IP address of the OBS Studio machine.

## Upload bandwidth limits

Stream Sprout sends a separate copy of the stream to every enabled destination. Your required upload bandwidth grows linearly with the number of active services.

For example, broadcasting a 6 Mbps stream to three platforms requires at least 18 Mbps of steady upload bandwidth, plus extra headroom for network jitter and audio overhead.

- Test your total bitrate with [Twitch `?bandwidthtest=true`](Configuration#testing-with-bandwidthtesttrue) before going live when you add new destinations.
- Local archiving (`archive_stream: true`) writes only to disk and uses no extra upload bandwidth.
- When you lack enough upload bandwidth from home, run Stream Sprout on a well-connected remote host reached over a VPN or SSH tunnel so your home connection uploads only once.

## Protocol and transcoding limits

- **Ingest protocol:** The local listener (`server:`) uses plain `rtmp://` only.
- **Destination protocols:** Outgoing `services:` entries support `rtmp://` and `rtmps://` when your `ffmpeg` binary includes TLS support.
- **No transcoding:** Stream Sprout runs FFmpeg with `-c:v copy -c:a copy`. It cannot downscale resolution or lower bitrate per destination.
