# nixOS/modules/home-manager/applications/aichat/default.nix
{ lib, pkgs, ... }:

let
    aichatPackage = pkgs.aichat.overrideAttrs (old: {
    src = ../../../../packages/aichat;

    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ [ pkgs.pkg-config ];

    buildInputs =
      (old.buildInputs or [])
      ++ [ pkgs.oniguruma ];
  });
in
{
  imports = [
    ./web-search.nix
    ./github-repo.nix
    ./nix-search.nix
  ];

  programs.aichat = {
    enable = true;
    package = aichatPackage;

    settings = {
      model = "ollama:gemma4:12b";
      function_calling = true;
      use_tools = "web_search,github_repo,nix_search";

      rag_embedding_model = "ollama:bge-m3";
      rag_top_k = 12;
      rag_chunk_size = 1000;
      rag_chunk_overlap = 150;

      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://127.0.0.1:11435/v1";

          patch.chat_completions = {
            "qwen3:8b".body = {
              reasoning_effort = "none";
            };
            "gemma4:12b".body = {
              reasoning_effort = "none";
              #max_tokens = 8192;
              max_tokens = 16394;
            };
          };

          models = [
            {
              name = "gemma4:12b";
            }
            {
              name = "qwen3:8b";
            }
            {
              name = "nomic-embed-text";
              type = "embedding";
              default_chunk_size = 1000;
              max_batch_size = 50;
            }
            {
              name = "bge-m3";
              type = "embedding";
              default_chunk_size = 1000;
              max_batch_size = 50;
            }
          ];
        }
      ];

      rag_template = ''
        Answer questions using the supplied NixOS configuration context.

        Rules:
        - Treat the current host configuration and its imported modules as authoritative.
        - Do not treat backup, archived, experimental, or unused configurations as active.
        - Distinguish between a package being installed and a feature being enabled.
        - Trace imports when determining which configuration declarations apply.
        - Distinguish between NixOS options and Home Manager options.
        - When asked whether something is enabled or disabled, identify the exact option and its value.
        - Do not infer an option's value from the presence of a package, module, import, or configuration file.
        - If the supplied context does not establish the answer, say so.
        - Cite the source filename and relevant option in your answer.

        <context>
        __CONTEXT__
        </context>

        <user_query>
        __INPUT__
        </user_query>
      '';
    };
  };

  xdg.configFile."aichat/functions/functions.json".text =
  builtins.toJSON (import ./functions.nix);
}

