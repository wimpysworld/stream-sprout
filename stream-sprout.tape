# Stream Sprout demo tape. Record with `just record`.

Output .demo.mp4

Set Shell "/bin/sh"
Set Columns 74
Set Rows 26
Set FontFamily "Fira Code"
Set FontSize 18
Set Padding 16
Set Framerate 20
Set TypingSpeed 55ms
Set Theme "Catppuccin Mocha"
Set CursorBlink false

Hide
Type 'cd "${STREAM_SPROUT_DEMO_DIR:-.}" && clear'
Enter
Sleep 200ms
Show

Sleep 500ms
Type "stream-sprout"
Enter
Wait+Screen@20s /FFmpeg is streaming/
Sleep 5.5s
Screenshot pages/demo-still.png
Sleep 3s
Ctrl+C
Wait+Screen@10s /stream-sprout-[0-9]/
Sleep 2.5s
