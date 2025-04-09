{
  stdenv,
  callPackage,
  alice-vision ? callPackage ./alice-vision.nix {},
  fetchFromGitHub,
  python3,
  patchelf,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "meshroom";
  version = "2023.3.0";

  nativeBuildInputs = [
    (python3.pkgs.cx-freeze.overridePythonAttrs (prev: {
      # version = "8.1.0";
      postPatch = "";

      # propagatedBuildInputs = prev.propagatedBuildInputs ++ [python3.pkgs.patchelf];

      buildInputs = prev.buildInputs ++ [patchelf];
      nativeBuildInputs = [patchelf];      
      nativeCheckInputs = prev.nativeCheckInputs ++ [patchelf];
      
      # nativeBuildInputs = prev.nativeBuildInputs ++ [patchelf];
      # buildInputs = prev.buildInputs ++ [patchelf];
      
      # nativeBuildInputs = prev.nativeBuildInputs ++ [patchelf];
    }))
  ];

  # propagatedBuildInputs = [ flask ];

  src = fetchFromGitHub {
    owner = "alicevision";
    repo = "Meshroom";

    rev = "v${version}";
    hash = "sha256-qt1FpmihEq3pCRFNr7jc3SD68DteGntJsLzOHn/cgeE=";

    # fetchSubmodules = true;    
  };
}

  
  
