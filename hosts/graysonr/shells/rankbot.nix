{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  
  packages = [ 
    pkgs.nodejs 
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
      fastapi
      uvicorn
      langgraph
      langgraph-cli
      #langgraph-api # Isn't in nixpkgs
      langchain
      langchain-core
      langchain-openai

      redis
      motor
    ]))
    pkgs.python311Packages.pip 
    pkgs.vscode 
    pkgs.brave 
  ]; # Installs packages into environment

  inputsFrom = [ pkgs.bat ]; # Installs dependencies of pkgs.bat, such as rust compiler

  # hook executes when shell launches 
  shellHook = ''
    echo "Welcome to the Dev shell!"
    cd ~/Projects/wattsai/SEOLinkBuilder/
    git config credential.helper store # Use stored credentials to avoid repeated manual entry
    code .
    kitty --detach gitui # Make separate terminal instance and launch gitui in it
  '';

  test = "AAAAAA"; # values not known as shell options will instead be set as env variables

}
