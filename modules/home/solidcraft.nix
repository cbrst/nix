{ inputs, pkgs, ... }:
{
  # Built from source by upstream's flake; there is no binary cache.
  home.packages = [ inputs.solidcraft.packages.${pkgs.stdenv.hostPlatform.system}.solidcraft ];
}
