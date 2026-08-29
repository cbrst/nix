{
  inputs,
  settings,
  configLib,
  ...
}:
{
  # A profile is a named group of reusable NixOS modules.
  imports = [
    ./hardware-configuration.nix
    ../../../profiles/nixos/desktop.nix
  ];

  # This value is specific to this computer.
  networking.hostName = "example-nixos";

  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  # NixOS owns the account itself. Home Manager below owns files and packages
  # inside that account's home directory.
  users.users.example-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # Home Manager runs as part of this NixOS configuration. It uses the
  # system's package set and installs packages into the named user's account.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs settings configLib; };
    users.example-user = {
      imports = [
        ../../../users/example-user/home.nix
        ../../../profiles/home/development.nix
      ];
    };
  };
}
