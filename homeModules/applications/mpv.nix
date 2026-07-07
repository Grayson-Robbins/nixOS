{
    programs.mpv.enable = true;

  programs.mpv.config = {
      vo = "drm";
    gpu-context = "drm";
      keep-open = true;
    };

  programs.mpv.bindings = {
      "RIGHT" = "seek 10";
    "LEFT" = "seek -10";
    };
}

