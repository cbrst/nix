{
  lib,
  python3Packages,
  fetchFromGitHub,
  qt6,
}:

let
  appId = "io.github.switch_bros.EasySCSModManager";
in
python3Packages.buildPythonApplication rec {
  pname = "easy-scsmodmanager";
  version = "1.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Switch-Bros";
    repo = "easy-scsmodmanager";
    tag = "v${version}";
    hash = "sha256-LdXzW01is6MFV4LzQv75DMDNaO/+/vmu92BLM+xQSXs=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    pyqt6
    pycryptodome
    vdf
    httpx
    pillow
  ];

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];
  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  # Let buildPythonApplication's wrapper carry the Qt plugin paths too,
  # instead of wrapping the entry point twice.
  dontWrapQtApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  # Same desktop integration files the upstream AUR package installs.
  postInstall = ''
    res=easy_scsmodmanager/resources
    install -Dm644 "$res/${appId}.desktop" -t "$out/share/applications"
    install -Dm644 "$res/icon.svg" "$out/share/icons/hicolor/scalable/apps/${appId}.svg"
    install -Dm644 "$res/icon.png" "$out/share/icons/hicolor/512x512/apps/${appId}.png"
    install -Dm644 "$res/${appId}.metainfo.xml" -t "$out/share/metainfo"
  '';

  # The upstream suite needs pytest-qt and a display.
  doCheck = false;
  pythonImportsCheck = [ "easy_scsmodmanager" ];

  meta = {
    description = "Mod and profile manager for Euro Truck Simulator 2 and American Truck Simulator";
    homepage = "https://github.com/Switch-Bros/easy-scsmodmanager";
    license = lib.licenses.gpl3Plus;
    mainProgram = "easy-scsmodmanager";
    platforms = lib.platforms.linux;
  };
}
