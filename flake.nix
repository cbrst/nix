{
  description = "Reusable NixOS and Home Manager configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.forall.systems" ];
    extra-trusted-public-keys = [
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
    ];
  };

  # Inputs are external Nix projects this configuration depends on.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    affinity-nix.url = "github:mrshmllow/affinity-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      # Use the same nixpkgs revision for NixOS and Home Manager.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brave-origin = {
      url = "github:Daniel-42-z/brave-origin-flake";
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

    # Claude Code plugins (linked via programs.claude-code.plugins)
    claude-kit = {
      url = "github:JohnnyVizz/claude-kit";
      flake = false;
    };

    cache-tax = {
      url = "github:karanb192/cache-tax";
      flake = false;
    };

    claude-code-playground = {
      url = "github:anthropics/claude-code-playground";
      flake = false;
    };

    claude-code-filetree = {
      url = "github:data-goblin/claude-code-filetree";
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
      defaultSettings = {
        fonts = {
          sans = "0xPropo";
          mono = "0xProto";
          terminalSize = 11;
        };
        gaming.vrrOutput = null;
        theme = import ./lib/themes.nix { family = "vscode2026"; };
      };

      # Shared helper for standalone Home Manager configurations.
      configLib = import ./lib { inherit inputs; };
    in
    {
      overlays.typescript-language-server-pnpm-hash-fix = import ./overlays/typescript-language-server-pnpm-hash-fix.nix;

      # The Home Manager Neovim as a standalone package, built from the same
      # definition. Run with: nix run .#nvim (or .#nvim-lite for the smaller
      # variant without AI, debugging, and project-language tooling).
      packages =
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-darwin"
          ]
          (
            system:
            let
              pkgs = configLib.mkPkgs system;
              mkNeovim =
                features:
                import ./modules/home/neovim/package.nix {
                  inherit pkgs inputs features;
                  inherit (pkgs) lib;
                  settings = defaultSettings;
                };
            in
            {
              nvim = mkNeovim { };
              nvim-lite = mkNeovim (import ./modules/home/neovim/lite.nix);
            }
          );

      # Apply with: sudo nixos-rebuild switch --flake .#example-nixos
      nixosConfigurations.example-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs defaultSettings configLib; };
        modules = [
          ./hosts/nixos/example-nixos
          home-manager.nixosModules.home-manager
        ];
      };

      nixosConfigurations.asgard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs defaultSettings configLib; };
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
        inherit defaultSettings;
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
        inherit defaultSettings;
        modules = [
          ./users/example-user/home.nix
          ./hosts/home/macbook.nix
        ];
      };

      homeConfigurations."cbrst@niflheim" = configLib.mkHome {
        system = "aarch64-darwin";
        username = "cbrst";
        homeDirectory = "/Users/cbrst";
        inherit defaultSettings;
        modules = [
          ./users/cbrst/home.nix
          ./hosts/home/niflheim.nix
        ];
      };
    };
}
