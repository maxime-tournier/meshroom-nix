{
  stdenv,

  fetchFromGitHub,
  fetchpatch,
  
  cmake,

  flann,
  coin-utils,
  osi,
  clp,

  cudaPackages,
  cudatoolkit,

  libe57format,
  lemon-graph,

  boost177,
  openexr,      
  nanoflann,
  openimageio,
  expat,
  eigen,
  onnxruntime,
  ceres-solver,
  lz4,

  assimp,
  geogram,
  openmesh,
  xercesc,
  
}:

let toolchain = [
      cmake
    ];
in

let openimageio-boost177 = openimageio.override {
      boost = boost177;
    };
in

# cmake support requires 1.9.2 instead of 1.9.1
let flann-cmake = flann.overrideAttrs (final: prev: rec {
      version = "1.9.2";

      src = prev.src.override {
        rev = version;
        sha256 = "sha256-5GCz28CbnPDQhEz6axFiQZMmOasd2Rph4a/bMQ53T2Q=";
      };
      
      patches = [];
      
    });
in
# fetch PR w/cmake support
let coin-utils-cmake = coin-utils.overrideAttrs (final: prev: {
      src = prev.src.override {
        rev = "c3cef3f";
        hash = "sha256-jU+4kjgnQ6allsTtRbMP0+SG8lLvKNcOWZP5Q024SUM=";
      };

      doCheck = false;
      nativeBuildInputs = [cmake];
      patches = [];
    });
in
# fetch PR w/cmake support
let osi-cmake = osi.overrideAttrs (final: prev: {
      src = prev.src.override {
        rev = "f59c5b5";
        hash = "sha256-EMh0hZtgpD9P2XGvGsj9Pt9qibDQq1CVYwhZEHIhx2Q=";
      };

      doCheck = false;
      nativeBuildInputs = [cmake coin-utils-cmake];
      patches = [];
    });
in
# fetch PR w/cmake support
let clp-cmake = (clp.override {
      osi = osi-cmake;
    }).overrideAttrs (final: prev: {
      src = prev.src.override {
        rev = "7693f5e";
        hash = "sha256-ChXh44nbN3sQBe8sUXtrDq2Y9/WtQkbH4J1R1YU8R1M=";
      };

      doCheck = false;
      nativeBuildInputs = [cmake coin-utils-cmake osi-cmake];
      patches = [];
    });
in
let nvcc = cudaPackages.cuda_nvcc;
in
let cudart = cudaPackages.cuda_cudart;
in
let cuda = [cudatoolkit nvcc cudart];
in
let libe57format-shared = libe57format.overrideAttrs (prev: {
      postInstall = "";
      doCheck = false;
      cmakeFlags = prev.cmakeFlags ++ [ "-DE57_BUILD_SHARED=ON" ];
    });
in
# fixes for c++20
let lemon-graph-dev = lemon-graph.overrideAttrs {
      src = fetchFromGitHub {
        owner = "MultiFlow";
        repo = "LEMON";

        rev = "master";
        hash = "sha256-nOX40N6RvIoHrafRHkFIGJjolCvq5IILH5NQ3IOLbbE=";
      };

      patches = [
        (fetchpatch {
          url = "https://lemon.elte.hu/trac/lemon/raw-attachment/ticket/631/93c983122692.patch";
          hash = "sha256-62S2kIYZkff344xTB4S7PSZ2VaQupXBo6AXc/j1S3zc=";
        })
      ];
    };

    doCheck = false;
in
let build-deps = [
      boost177
      openexr      
      nanoflann
      expat
      eigen
      onnxruntime
      ceres-solver
      lz4
      assimp
      geogram
      openmesh
      xercesc

      openimageio-boost177
      
      flann-cmake
      coin-utils-cmake
      clp-cmake
      osi-cmake
      lemon-graph-dev
      libe57format-shared
      

    ] ++ cuda;
in

let build-inputs = toolchain ++ build-deps;
in

stdenv.mkDerivation rec {
  pname = "alice-vision";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "alicevision";
    repo = "AliceVision";

    rev = "v${version}";
    hash = "sha256-H7XiZBA9IHmp644PsH3EvwBamoq8+SFZJ66bkRPFJ6A=";

    fetchSubmodules = true;    
  };

  patches = [ ./alice-vision-osiclp.patch ];
  
  nativeBuildInputs = build-inputs;

  # use gcc-13 for cuda
  CUDAHOSTCXX = "${cudaPackages.backendStdenv.cc}/bin/gcc";

  openimageio = openimageio-boost177;
  boost = boost177;
  coin-utils = coin-utils-cmake;
  clp = clp-cmake;
  osi = osi-cmake;
}
