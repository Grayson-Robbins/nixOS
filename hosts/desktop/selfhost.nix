{ ... }:
{
  imports = [
    ../../modules/selfhosted
  ];

  services.selfhost = {
    enable = true;

    immich.enable = true;
    sure.enable = true;
    grocy.enable = true;
  };

}
