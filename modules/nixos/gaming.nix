{ pkgs, ... }:
{
  hardware.xone.enable = true;

  programs.steam = {
    enable = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    enableWsi = true;
    capSysNice = true;
  };

  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };

  services.irqbalance.enable = true;

  # LAVD targets low-latency interactive workloads and can fall back to the
  # kernel scheduler if the sched-ext process exits.
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
}
