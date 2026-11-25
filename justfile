# Requires just 1.23.0 or later.
import 'just/loader.just'

# List available recipes
default:
    @just --list

# Record pages/demo.webp and pages/demo-still.png from stream-sprout.tape using ntrecord
record:
    #!/usr/bin/env bash
    set -euo pipefail

    for tool in ntrecord ffmpeg; do
        command -v "$tool" >/dev/null || {
            printf "just record: %s not found; enter the Nix shell with 'nix develop'\n" "$tool" >&2
            exit 1
        }
    done

    repo_root="$PWD"
    tmp_dir="$(mktemp -d)"
    pids=()

    port_listening() {
        local port="$1"
        local port_hex
        port_hex="$(printf '%04X' "$port")"
        if [[ -r /proc/net/tcp ]] && grep -qE "^[[:space:]]*[0-9]+:[[:space:]]+[0-9A-Fa-f]+:${port_hex}[[:space:]]+00000000:0000[[:space:]]+0A[[:space:]]" /proc/net/tcp; then
            return 0
        elif command -v lsof >/dev/null 2>&1 && lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
            return 0
        fi
        return 1
    }

    wait_for_port() {
        local port="$1"
        local _i
        for _i in $(seq 1 150); do
            if port_listening "$port"; then
                return 0
            fi
            sleep 0.1
        done
        return 1
    }

    cleanup() {
        local pid
        for pid in "${pids[@]}"; do
            kill "$pid" 2>/dev/null || true
        done
        for pid in "${pids[@]}"; do
            wait "$pid" 2>/dev/null || true
        done
        rm -f -- "$repo_root/.demo.mp4"
        if [[ -n "${tmp_dir:-}" && -d "$tmp_dir" ]]; then
            rm -rf -- "$tmp_dir"
        fi
    }
    trap cleanup EXIT

    for port in 1935 1936 1937 1938 1939; do
        if port_listening "$port"; then
            printf 'just record: port %s is already in use\n' "$port" >&2
            exit 1
        fi
    done

    mkdir -p "$tmp_dir/recordings" pages

    cat > "$tmp_dir/stream-sprout.yaml" <<'EOF'
    server:
      ip: 127.0.0.1
      port: 1935
      app: sprout
      key: a1b2c3d4-e5f6-7890-abcd-ef1234567890
      archive_stream: true
      archive_path: ./recordings

    services:
      owncast:
        enabled: true
        rtmp_server: rtmp://127.0.0.1:1936/live
        key: key
      peertube:
        enabled: true
        rtmp_server: rtmp://127.0.0.1:1937/live
        key: key
      twitch:
        enabled: true
        rtmp_server: rtmp://127.0.0.1:1938/live
        key: key
      youtube:
        enabled: true
        rtmp_server: rtmp://127.0.0.1:1939/live
        key: key
    EOF

    # Start four loopback RTMP sinks so stream-sprout forwards cleanly to all targets.
    for port in 1936 1937 1938 1939; do
        ffmpeg -nostdin -hide_banner -loglevel error \
            -listen 1 -i "rtmp://127.0.0.1:${port}/live/key" \
            -c copy -f null - >/dev/null 2>&1 &
        pids+=("$!")
    done

    for port in 1936 1937 1938 1939; do
        if ! wait_for_port "$port"; then
            printf 'just record: loopback RTMP sink on port %s did not start\n' "$port" >&2
            exit 1
        fi
    done

    # Once stream-sprout opens port 1935, pause briefly so standing-by is visible,
    # then push a synthetic BT.709 H.264 High + AAC stereo test stream.
    (
        if wait_for_port 1935; then
            sleep 1.2
            exec ffmpeg -nostdin -hide_banner -loglevel error -re \
                -f lavfi -i color=c=black:s=1920x1080:r=60 \
                -f lavfi -i sine=frequency=440:sample_rate=48000 \
                -ac 2 \
                -c:v libx264 -preset superfast -profile:v high -pix_fmt yuv420p \
                -color_range tv -colorspace bt709 -color_primaries bt709 -color_trc bt709 \
                -b:v 6000k -maxrate 6000k -bufsize 12000k -g 120 \
                -c:a aac -b:a 160k -ar 48000 \
                -t 30 -f flv "rtmp://127.0.0.1:1935/sprout/a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
                >/dev/null 2>&1
        fi
    ) &
    pids+=("$!")

    font_env=()
    if [[ -z "${NTRECORD_FONT_PATH:-}" && -d /run/current-system/sw/share/X11/fonts ]]; then
        font_env=(NTRECORD_FONT_PATH=/run/current-system/sw/share/X11/fonts)
    fi

    env -u DIRENV_DIR -u DIRENV_FILE -u DIRENV_DIFF -u DIRENV_WATCHES \
        -u PROMPT_COMMAND -u BASH_ENV \
        PATH="$repo_root:$PATH" \
        STREAM_SPROUT_DEMO_DIR="$tmp_dir" \
        STREAM_SPROUT_STATUS_INTERVAL=3 \
        "${font_env[@]}" \
        ntrecord stream-sprout.tape

    ffmpeg -y -v error -i "$repo_root/.demo.mp4" -c:v libwebp_anim -lossless 1 -loop 0 pages/demo.webp
