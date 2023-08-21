{
  mkPythonPoetryScript = { name, pkgs }: pkgs.poetry2nix.mkPoetryApplication {
    meta.mainProgram = name;
    projectDir = ../scripts/${name};
  };
}
