# This function receives the flake inputs and returns helpers for flake.nix.
{ inputs }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nur
    ;

  configLib = rec {
    renderTemplate =
      replacements: path:
      builtins.replaceStrings (builtins.attrNames replacements) (builtins.attrValues replacements) (
        builtins.readFile path
      );

    # Build a Home Manager configuration for a non-NixOS Linux or macOS user.
    mkHome =
      {
        system,
        username,
        homeDirectory,
        modules,
        defaultSettings,
      }:
      home-manager.lib.homeManagerConfiguration {
        # Import nixpkgs for the target CPU and operating system combination.
        pkgs = import nixpkgs {
          inherit system;

          config.allowUnfree = true;

          # Add NUR packages, including Firefox add-ons, to pkgs.
          overlays = [
            nur.overlays.default
          ];
        };

        # Hosts derive their final settings from these shared defaults.
        extraSpecialArgs = { inherit inputs defaultSettings configLib; };

        modules = [
          # These values identify the account being configured.
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ]
        ++ modules;
      };
  };
in
configLib
