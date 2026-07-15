{ pkgs, ... }:
{
    home.packages = with pkgs; [
      git
      docker-compose
      ollama
      llama-cpp
      python3Packages.huggingface-hub
    ];

    home.file.".local/share/odysseus/allowed".source = ./files/allowed;
    home.file.".local/share/odysseus/notes".source = ./files/notes;
}
