{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.phpstorm
    jetbrains.pycharm
    jetbrains.webstorm
  ];
}
