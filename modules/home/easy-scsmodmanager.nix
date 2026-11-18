{ pkgs, ... }:
{
  # ETS2/ATS mod and profile manager.
  home.packages = [ (pkgs.callPackage ../../packages/easy-scsmodmanager { }) ];
}
