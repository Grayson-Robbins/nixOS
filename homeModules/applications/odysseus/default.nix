{ pkgs, ... }:
{
    home.packages = with pkgs; [
      git
      docker-compose
      ollama
    ];

    home.file.".local/share/odysseus/allowed".source = ./files/allowed;
    home.file.".local/share/odysseus/notes".source = ./files/notes;
}
