{ ... }:
{
  imports = [
    ../../modules/selfhosted
  ];

  services.selfhost = {
    enable = true;

    docker.networks.ai.enable = true;

    immich.enable = true;
    sure.enable = true;
    grocy.enable = true;
    ollama.enable = true;
  };

}
