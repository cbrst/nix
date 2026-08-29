{
  lib,
  pkgs,
  settings,
  ...
}:
let
  kanagawaGtkTheme = pkgs.callPackage ../../packages/kanagawa-gtk-theme { };
  font = "${settings.fonts.sans} 11";
  gtkTheme = settings.theme.apps.gtk.name;

  gtkSettings = ''
    [Settings]
    gtk-theme-name=${gtkTheme}
    gtk-icon-theme-name=Fluent-dark
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
    pkgs.fluent-icon-theme
    pkgs.papirus-icon-theme
  ]
  ++ lib.optional (settings.theme.family == "kanagawa") kanagawaGtkTheme;

  environment.etc = {
    "xdg/gtk-3.0/settings.ini".text = gtkSettings;
    "xdg/gtk-4.0/settings.ini".text = gtkSettings;
  };

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = gtkTheme;
        icon-theme = "Fluent-dark";
        font-name = "${font}";
      };
    }
  ];
}
