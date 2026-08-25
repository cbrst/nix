{ pkgs, ... }:
{
  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;

  environment.systemPackages = [
    pkgs.xwayland-satellite
  ];
}
