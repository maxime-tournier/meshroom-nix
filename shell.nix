{
  pkgs ? import <nixpkgs> {
    config = { allowUnfree = true; };
  },
}:
with pkgs;

let
  nixgl = import <nixgl> {};    
in

let alice-vision = callPackage ./alice-vision.nix {};
in
let meshroom = callPackage ./meshroom.nix {};
in
let qt-alice-vision = callPackage ./qt-alice-vision.nix {};
in
let meshroom = callPackage ./meshroom.nix {};
in

pkgs.mkShell {

  QT_QPA_PLATFORM_PLUGIN_PATH = "${qt5.qtbase}/lib/qt-${qt5.qtbase.version}/plugins/platforms";
  # QT_DEBUG_PLUGINS = 1;
  # QML_IMPORT_TRACE = 1;
  # MESHROOM_OUTPUT_QML_WARNINGS = 1;

  QT_PLUGIN_PATH = pkgs.lib.makeSearchPath qt5.qtbase.qtPluginPrefix [qt5.qtbase];
  QML2_IMPORT_PATH = "${pkgs.lib.makeSearchPath pkgs.qt5.qtbase.qtQmlPrefix [
    qt5.qtgraphicaleffects
    qt5.qt3d
    qt5.qtquickcontrols2.bin
    qt5.qtquickcontrols
    qt5.qtlocation
    qt5.qtcharts.bin
  ]}:${qt-alice-vision}/qml";
  
  ALICEVISION_ROOT = "${alice-vision}";
  
  nativeBuildInputs = [
    alice-vision
    qt-alice-vision
    meshroom
    python3
    python3.pkgs.distutils
    python3.pkgs.pyside2
    python3.pkgs.psutil
    python3.pkgs.requests
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qtquickcontrols2
    qt5.qtquickcontrols
    qt5.wrapQtAppsHook
    qt5.qtgraphicaleffects
    qt5.qt3d
    qt5.qtlocation
    qt5.qtcharts
    nixgl.nixGLMesa
  ];
}
