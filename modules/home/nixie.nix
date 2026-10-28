{ pkgs, ... }:
{
  # Day-to-day flake management: update, rebuild, diff, clean, roll back.
  home.packages = [ (pkgs.callPackage ../../packages/nixie { }) ];
}
