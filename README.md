Bookman Cockpit Linux Edition
=============================

This is a small script that downloads the windows installer from their website, unpacks it, replaces the platform detection and start it up similar to how the `bookman.exe` would do on windows.

Running
-------


```bash
nix run github:csicar/bookman-linux
```


AppImage for non-nix installs
----------------------------

```bash
nix bundle --bundler github:ralismark/nix-appimage github:csicar/bookman-linux
```