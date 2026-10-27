{
  writeShellApplication,
  coreutils,
  imagemagick,
  libnotify,
  noctalia,
  util-linux,
}:

writeShellApplication {
  name = "set-noctalia-wallpaper";
  runtimeInputs = [
    coreutils
    imagemagick
    libnotify
    noctalia
    util-linux
  ];
  text = builtins.readFile ./set-noctalia-wallpaper.sh;
}
