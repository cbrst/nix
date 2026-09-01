{ config, ... }:
{
  # Enable ca-derivations, flakes and the modern `nix` command for
  # this NixOS machine.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "ca-derivations"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Apply the count limit before the age-based garbage collection runs.
  systemd.services.nix-gc.preStart = ''
    ${config.nix.package}/bin/nix-env \
      --profile /nix/var/nix/profiles/system \
      --delete-generations +10
  '';

  # Pin this after the first installed NixOS release. It controls compatibility
  # defaults, not the version of packages installed from nixpkgs.
  system.stateVersion = "26.05";

  programs.zsh.enable = true;
}
