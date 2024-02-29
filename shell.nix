#let
#  # 
#  # Note that I am using a specific version from NixOS here because of 
#  # https://github.com/NixOS/nixpkgs/issues/267916#issuecomment-1817481744
#  #
#  nixpkgs = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz";
#  #nixpkgs = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/51f732d86fac4693840818ad2aa4781d78be2e89.tar.gz";
#  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
#  pythonPackages = pkgs.python311Packages;

with import <nixpkgs> { };
let
  # For packages pinned to a specific version
  pinnedHash = "933d7dc155096e7575d207be6fb7792bc9f34f6d"; 
  pinnedPkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/${pinnedHash}.tar.gz") { };
  pythonPackages = python3Packages;
in pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./.venv";
  buildInputs = [
    # A Python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    pythonPackages.python

    # This executes some shell code to initialize a venv in $venvDir before
    # dropping into the shell
    pythonPackages.venvShellHook
    pinnedPkgs.virtualenv
    # Those are dependencies that we would like to use from nixpkgs, which will
    # add them to PYTHONPATH and thus make them accessible from within the venv.
    pythonPackages.numpy
    pinnedPkgs.armadillo # needed for fringe lib
    pinnedPkgs.blas # needed for fringe lib
    pinnedPkgs.openssl
    pinnedPkgs.git
    pinnedPkgs.libxml2
    pinnedPkgs.libxslt
    pinnedPkgs.libzip
    pinnedPkgs.zlib
    pinnedPkgs.gnused
    pythonPackages.pip
    pythonPackages.cython
    pythonPackages.numpy
    pythonPackages.setuptools
    pythonPackages.gdal
    pythonPackages.pybind11
    #python311Packages.jupyterlab
    pythonPackages.ipympl
    pinnedPkgs.cmake
    pinnedPkgs.pkg-config
    pinnedPkgs.xorg.libX11
    pinnedPkgs.xorg.libX11.dev
    pinnedPkgs.gfortran9
    pinnedPkgs.fftw
    pinnedPkgs.fftwFloat
    pinnedPkgs.motif
    pinnedPkgs.opencv
    pinnedPkgs.vim
    pinnedPkgs.git
    pinnedPkgs.wget
    pinnedPkgs.screen
    pinnedPkgs.gotop
  ];
  # Run this command, only after creating the virtual environment
  PROJECT_ROOT = builtins.getEnv "PWD";

  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install -r requirements.txt
    export PATH=$ISCE_HOME/applications:$PATH
    export ISCE_STACK=$PWD/isce2/contrib/stack
    export PATH=$PATH:$ISCE_HOME/bin:$ISCE_HOME/applications:$PWD/fringe-build/bin:$PWD/snaphu-build/
    export PYTHONPATH=$PYTHONPATH:$PWD/isce2-build/packages:$PWD/fringe-build/python:$ISCE_STACK
    export PATH=$PATH:$PWD/isce2-build/packages/isce/applications/
    # This needs to be last to shadow out scripts with duplicate names
    export PATH=$PATH:$ISCE_STACK/topsStack
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/fringe-build/lib:${stdenv.cc.cc.lib}/lib/
    ./setup.sh
    python test.py

  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';


}
