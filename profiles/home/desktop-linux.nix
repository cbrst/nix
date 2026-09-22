{ ... }:
{
  imports = [
    ./desktop-base.nix
    ../../modules/home/affinity
    ../../modules/home/brave-origin
    ../../modules/home/firefox
    ../../modules/home/imv
    ../../modules/home/mpv
    ../../modules/home/nautilus
    ../../modules/home/nextcloud.nix
    ../../modules/home/niri
    ../../modules/home/noctalia
    ../../modules/home/sone.nix
    ../../modules/home/tailscale.nix
  ];
}
