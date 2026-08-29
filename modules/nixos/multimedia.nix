{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    imv
    mpv
  ];
}
