{ pkgs }:

{
  /* Create a derivation for a Python script managed by Poetry in scripts/

    Enforces the directory convention where a Poetry project is supposed to
    exist in scripts/${scriptName}/ and export a script with the same name
    under [tool.poetry.scripts].
  */
  mkPythonPoetryScript = { name }:
    let python = pkgs.python3;
    in
    pkgs.poetry2nix.mkPoetryApplication {
      inherit python;
      projectDir = ../scripts/${name};
      doCheck = true;
      # nativeCheckInputs = [ pkgs.python3Packages.pytestCheckHook ];

      checkPhase = ''
        runHook preCheck
        pytest
        runHook postCheck
      '';

      meta.mainProgram = name;
    };

  /* Create a derivation for a shell script in scripts/

    Enforces the directory convention scripts/${scriptName}/${scriptName}.sh.
  */
  mkShellScript = { name, runtimeInputs }: pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = builtins.readFile ../scripts/${name}/${name}.sh;
  };
}
