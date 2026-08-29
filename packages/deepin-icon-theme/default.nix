{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
}:

stdenvNoCC.mkDerivation {
  pname = "deepin-icon-theme";
  version = "2026.02.27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = "deepin-icon-theme";
    tag = "2026.02.27";
    hash = "sha256-hSbTrA6MQkaZEGAe9MmvlUe8x+CHT6AWf4ahv5ikiyE=";
  };

  nativeBuildInputs = [ gtk3 ];
  dontBuild = true;
  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall

    for theme in bloom bloom-dark bloom-classic; do
      mkdir -p "$out/share/icons/$theme"
      cp -r "$theme/." "$out/share/icons/$theme/"
    done

    # Upstream retains UOS activator links whose proprietary targets are absent.
    find "$out/share/icons" -xtype l -delete

    for theme in bloom bloom-dark bloom-classic; do
      gtk-update-icon-cache -f "$out/share/icons/$theme"
    done

    runHook postInstall
  '';

  meta = {
    description = "Deepin Bloom icon themes";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
