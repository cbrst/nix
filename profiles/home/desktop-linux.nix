{ ... }:
{
  imports = [
    ./desktop-base.nix
    ../../modules/home/firefox
    ../../modules/home/imv
    ../../modules/home/mpv
    ../../modules/home/nautilus
    ../../modules/home/niri
    ../../modules/home/noctalia
    ../../modules/home/tailscale.nix
  ];
}
