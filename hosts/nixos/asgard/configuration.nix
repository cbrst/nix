{
  inputs,
  lib,
  pkgs,
  defaultSettings,
  settings,
  configLib,
  ...
}:
{
  _module.args.settings = lib.recursiveUpdate defaultSettings {
    gaming.vrrOutput = "PNP(AOC) AG276QZD2 1322131231233";
  };

  nixpkgs.overlays = [ inputs.affinity-nix.overlays.default ];

  nix.settings = {
    extra-substituters = [ "https://cache.forall.systems" ];
    extra-trusted-public-keys = [
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
    ];
  };

  # A profile is a named group of reusable NixOS modules.
  imports = [
    ./hardware-configuration.nix
    ../../../modules/nixos/secure-boot.nix
    ../../../modules/nixos/gaming.nix
    ../../../profiles/nixos/desktop.nix
    ../../../profiles/nixos/development.nix
  ];

  # This value is specific to this computer.
  networking.hostName = "asgard";

  # set tailscale operator
  services.tailscale.extraSetFlags = [ "--operator=cbrst" ];

  # Set timezone
  time.timeZone = "Europe/Berlin";

  # This defines the bootloader used by the system.
  # Since Secure Boot is required, import profiles/nixos/secure-boot.nix
  # for the required toolchain
  boot.loader.limine = {
    enable = true;
    # Change this to true after enrolling the keys from Secure Boot Setup mode
    secureBoot.enable = true;
    maxGenerations = 10;
    extraEntries = ''
      /Windows
        protocol: efi_boot_entry
        entry: Windows Boot Manager
    '';
    resolution = "2560x1440x32";
    style = {
      backdrop = "171616";
      wallpapers = [ ];
      interface = {
        branding = "";
        resolution = "2560x1440";
        helpColor = "96bddf";
        helpColorBright = "96bddf";
      };
      graphicalTerminal = {
        font.scale = "1x1";
        foreground = "e2e0df";
        background = "171616";
        brightBackground = "454240";
        palette = "454240;e99696;98cdaa;dfd286;96bddf;eaa4c9;96d8e3;b1ada9";
      };
    };
  };

  # NixOS owns the account itself. Home Manager below owns files and packages
  # inside that account's home directory.
  users.users.cbrst = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "gamemode"
    ];
    shell = pkgs.zsh;
  };

  # Home Manager runs as part of this NixOS configuration. It uses the
  # system's package set and installs packages into the named user's account.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs settings configLib; };
    users.cbrst = {
      imports = [
        ../../../users/cbrst/home.nix
        ../../../profiles/home/development.nix
        ../../../profiles/home/desktop-linux.nix
        ../../../profiles/home/gaming.nix
      ];
    };
  };
}
