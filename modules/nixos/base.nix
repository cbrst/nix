{ ... }:
{
  # Enable ca-derivations, flakes and the modern `nix` command for
  # this NixOS machine.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "ca-derivations"
  ];

  # Pin this after the first installed NixOS release. It controls compatibility
  # defaults, not the version of packages installed from nixpkgs.
  system.stateVersion = "26.05";
}
