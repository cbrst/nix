{ config, ... }:
{
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    # Quad9
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::fe"
    "2620:fe::9"

    # Cloudflare fallback
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

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
