# SpotifyAsInput
A Bash Script to grab your Spotify Player's Output and use it as Input/Microphone for playing music over Microphone on Linux/Pipewire

This Script grabs your Spotify Audio Output and creates a Virtual Microphone, it also loads a Loopback so you can still hear the native Spotify Music.

Can be used to Micspam in TF2 or for any other reason you'd want to Play Music over a Microphone.

## Usage
1. Start the Script
   ```bash
   cd SpotifyAsInput
   sh ./SpotifyAsInput.sh
   ```
2. Start Spotify and play some music.
3. Open 'pavucontrol' (Volume Control).
4. Go to the 'Playback' tab and locate Spotify.
5. Change Spotify's output to '$VIRTUAL_SINK_DESCRIPTION'.
6. In whatever voice application , select 'Spotify Virtual Mic' as your *Music Input*

If you wish to talk in Discord etc. make sure you are using your actual microphone instead.

## Misc.
You can technically edit this Script to route any Applications Sound to a Virtual Microphone or even route multiple Outputs if you'd like.

### Tested on
CachyOS x86_64
Linux 6.15.2-2-cachyos

The MIT License (MIT)

Copyright (c) <2025> 0xInstrumentarium

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
