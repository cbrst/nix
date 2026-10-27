{
  writeShellApplication,
  coreutils,
  imagemagick,
  libnotify,
  noctalia,
}:

writeShellApplication {
  name = "set-noctalia-wallpaper";
  runtimeInputs = [
    coreutils
    imagemagick
    libnotify
    noctalia
  ];
  text = builtins.readFile ./set-noctalia-wallpaper.sh;
}
