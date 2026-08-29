{
  description = "Reusable NixOS and Home Manager configuration";

  # Inputs are external Nix projects this configuration depends on.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      # Use the same nixpkgs revision for NixOS and Home Manager.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI
    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rtk-src = {
      url = "github:rtk-ai/rtk/v0.42.4";
      flake = false;
    };

    # Add meowsoot as input to get the ghostty theme
    meowsoot = {
      url = "github:marekh19/meowsoot.nvim";
      flake = false;
    };

    kanagawa = {
      url = "github:rebelot/kanagawa.nvim";
      flake = false;
    };

    zshcs = {
      url = "github:yuys13/zshcs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs are the named configurations and helpers exported by this flake.
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      settings = {
        fonts = {
          sans = "0xPropo";
          mono = "0xProto";
        };
        theme = import ./lib/themes.nix { family = "meowsoot"; };
      };
      # Shared helper for standalone Home Manager configurations.
      configLib = import ./lib { inherit inputs; };
    in
    {
      # Apply with: sudo nixos-rebuild switch --flake .#example-nixos
      nixosConfigurations.example-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs settings configLib; };
        modules = [
          ./hosts/nixos/example-nixos
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.asgard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs settings configLib; };
        modules = [
          ./hosts/nixos/asgard
          home-manager.nixosModules.home-manager
        ];
      };

      # Apply with:
      # nix run github:nix-community/home-manager -- switch \
      #     --flake .#example-user@generic-linux
      homeConfigurations."example-user@generic-linux" = configLib.mkHome {
        system = "x86_64-linux";
        username = "example-user";
        homeDirectory = "/home/example-user";
        inherit settings;
        modules = [
          ./users/example-user/home.nix
          ./hosts/home/generic-linux.nix
        ];
      };

      # Apply with:
      # nix run github:nix-community/home-manager -- switch \
      #     --flake .#example-user@macbook
      homeConfigurations."example-user@macbook" = configLib.mkHome {
        system = "aarch64-darwin";
        username = "example-user";
        homeDirectory = "/Users/example-user";
        inherit settings;
        modules = [
          ./users/example-user/home.nix
          ./hosts/home/macbook.nix
        ];
      };
    };
}
