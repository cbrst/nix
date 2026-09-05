{ pkgs, ... }:
{
  imports = [
    ./desktop-base.nix
    ../../modules/home/karabiner
  ];

  home.packages = [
    pkgs.ice-bar
    pkgs.raycast
  ];
}
