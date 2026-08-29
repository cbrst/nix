{ pkgs, settings, ... }:
let
  deepin-icon-theme = pkgs.callPackage ../../packages/deepin-icon-theme { };
  font = "${settings.fonts.sans} 11";

  gtkSettings = ''
    [Settings]
    gtk-theme-name=Adwaita-dark
    gtk-icon-theme-name=bloom-dark
    gtk-application-prefer-dark-theme=1
    gtk-font-name=${font}
    gtk-xft-antialias=1
    gtk-xft-hinting=1
    gtk-xft-hintstyle=hintslight
    gtk-xft-rgba=none
  '';
in
{
  environment.systemPackages = [
    deepin-icon-theme
    pkgs.papirus-icon-theme
  ];

  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = gtkSettings;
    "xdg/gtk-4.0/settings.ini".text = gtkSettings;
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        icon-theme = "bloom-dark";
        font-name = "${font}";
      };
    }
  ];
}
