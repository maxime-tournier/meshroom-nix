
{
  stdenv,
  callPackage,
  alice-vision ? callPackage ./alice-vision.nix {},
  cmake,
  fetchFromGitHub,
  qt5,
  ceres-solver,
  openimageio,
  boost177,
  libxkbcommon,
  imath,
}:

let toolchain = [
      cmake
    ];
in
let build-deps = [
      alice-vision
      qt5.full
      ceres-solver
      alice-vision.openimageio
      alice-vision.boost
      alice-vision.coin-utils
      alice-vision.clp
      libxkbcommon
    ];
in    
let build-inputs = toolchain ++ build-deps;
in
  
stdenv.mkDerivation rec {
  pname = "qt-alice-vision";
  version = "2023.3.0";

  src = fetchFromGitHub {
    owner = "alicevision";
    repo = "QtAliceVision";

    rev = "v${version}";
    hash = "sha256-P+s852bDslr7ku8MuuSxokf0xyBBwGrNtw76xj+5AG8=";

    # fetchSubmodules = true;    
  };

  nativeBuildInputs = build-inputs;
  buildInputs = [alice-vision imath];
}
  
