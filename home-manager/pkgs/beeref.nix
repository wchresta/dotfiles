{
  python3Packages,
  fetchFromGitHub,
  lib,
}:

let
  rectangle-packer = python3Packages.buildPythonPackage {
    pname = "rectangle-packer";
    version = "2024-10-26";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "Penlect";
      repo = "rectangle-packer";
      rev = "46fa636fc8637081845151b4a0b16e8f60a57638";
      sha256 = "sha256-9mXfa9tDB2QE6hHxOxk9XvUjiov0dUBX54X4uRxwSvQ=";
    };

    build-system = with python3Packages; [ cython setuptools ];

    pythonImportsCheck = [ "rpack" ];

    meta = with lib; {
      description = "A Python module for rectangle packing utilities.";
      homepage = "https://github.com/Penlect/rectangle-packer";
      license = licenses.mit;
      maintainers = [ ];
    };
  };
in python3Packages.buildPythonApplication {
  pname = "beeref";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "rbreu";
    repo = "beeref";
    rev = "caed5c38016c9efea05f78d3f60178e0ba878cd4";
    hash = "sha256-wA0cqJgyirAqpZYoWjzSTiGX4FraTHXLCLWm2kALWn4=";
  };

  prePatch = ''
    # Relax install dependency requirements
    substituteInPlace setup.py \
      --replace "pyQt6>=6.5.0,<=6.6.1" "pyQt6" \
      --replace "pyQt6-Qt6>=6.5.0,<=6.6.1" ""
  '';

  propagatedBuildInputs = with python3Packages; [
    exif
    lxml
    pyqt6
    rectangle-packer
  ];

  # Writeable home directory needed for tests
  preCheck = ''
    export HOME=$TMPDIR
  '';
  checkInputs = with python3Packages; [
    httpretty
    pytest
  ];

  meta = with lib; {
    description = "A reference image viewer";
    homepage = "https://beeref.org/";
    longDescription = ''
      BeeRef lets you quickly arrange your reference images and view them while you create. Its minimal interface is designed not to get in the way of your creative process.
    '';
    license = with licenses; [ gpl3Plus ];
    maintainers = with maintainers; [ annaaurora ];
    mainProgram = "beeref";
  };
}

