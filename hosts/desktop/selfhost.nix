{ ... }:
{
  imports = [
    ../../modules/selfhosted
  ];

  services.selfhost = {
    enable = true;

    # Desktop-specific Docker DNS config
    docker.dns = [
      "192.168.1.1"
      "8.8.8.8" # Use external DNS for Sure app
    ];

    immich.enable = true;
    sure.enable = true;
    grocy.enable = true;
  };

}
