{ inputs, ... }:
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.noctalia-greeter = {
    enable = true;

    # Select Niri as the default session
    greeter-args = "--session niri";
  };
}
