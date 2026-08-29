{ config, pkgs, ... }:
{
  services.gvfs.enable = true;

  environment.systemPackages = [
    pkgs.nautilus
    pkgs.nautilus-python
  ];

  environment.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-4";

  xdg.mime.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
}
