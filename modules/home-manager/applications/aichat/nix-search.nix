
{ pkgs, ... }:

let
  nixSearchScript = pkgs.writeShellApplication {
    name = "nix_search";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.nh
    ];

    text = ''
      set -euo pipefail

      if [[ "$#" -ne 1 ]]; then
        echo "Usage: nix_search '<JSON arguments>'" >&2
        exit 2
      fi

      if [[ -z "''${LLM_OUTPUT:-}" ]]; then
        echo "LLM_OUTPUT must point to the tool output file." >&2
        exit 2
      fi

      input="$1"

      operation="$(jq -er '.operation | strings' <<< "$input")"
      query="$(jq -er '
        .query
        | strings
        | gsub("^\\s+|\\s+$"; "")
        | select(length > 0)
      ' <<< "$input")"

      channel="$(jq -r '.channel // "nixos-unstable"' <<< "$input")"
      limit="$(jq -r '.limit // 30' <<< "$input")"

      if ! [[ "$limit" =~ ^[0-9]+$ ]] || (( limit < 1 || limit > 100 )); then
        echo "limit must be an integer between 1 and 100." >&2
        exit 2
      fi

      if ! [[ "$channel" =~ ^[A-Za-z0-9._/-]+$ ]]; then
        echo "Invalid channel name." >&2
        exit 2
      fi

      case "$operation" in
        packages)
          response="$(
            nh search packages \
              --json \
              --channel "$channel" \
              --limit "$limit" \
              "$query"
          )"
          ;;
        nixos_options)
          response="$(
            nh search options \
              --json \
              --scope=nixpkgs \
              --channel "$channel" \
              --limit "$limit" \
              "$query"
          )"
          ;;
        home_manager_options)
          response="$(
            nh search options \
              --json \
              --scope=home-manager \
              --channel "$channel" \
              --limit "$limit" \
              "$query"
          )"
          ;;
        all_options)
          response="$(
            nh search options \
              --json \
              --scope=all \
              --channel "$channel" \
              --limit "$limit" \
              "$query"
          )"
          ;;
        *)
          echo "Unsupported operation: $operation" >&2
          exit 2
          ;;
      esac

      jq -e '
        type == "object" and
        (.results | type == "array")
      ' <<< "$response" > /dev/null || {
        echo "nh returned an unexpected JSON response." >&2
        exit 1
      }

      jq -c \
        --arg operation "$operation" \
        --arg query "$query" \
        --arg channel "$channel" \
        --argjson limit "$limit" '
        {
          operation: $operation,
          query: $query,
          channel: $channel,
          requested_scope: (
            if $operation == "nixos_options" then "nixpkgs"
            elif $operation == "home_manager_options" then "home-manager"
            elif $operation == "all_options" then "all"
            else null
            end
          ),
          elapsed_ms: (.elapsed_ms // null),
          result_count: (.results | length),
          results: (
            if $operation == "packages" then
              [
                .results[:$limit][] |
                {
                  package_attr_name,
                  package_pversion,
                  package_description
                }
              ]
            else
              [
              .results[] |
                {
                  option_name,
                  classification: .type,
                  value_type: .option_type,
                  source: .option_source
                }
              ]
            end
          ),
          notes: [
            "Results describe the selected Nix channel and search scope.",
            "Package availability does not establish that a package is installed.",
            "Option search results describe option definitions, not the evaluated value on the current host.",
            "NixOS options and Home Manager options are distinct.",
            "This tool does not search arbitrary third-party flakes."
          ]
        }
      ' <<< "$response" >> "$LLM_OUTPUT"
    '';
  };

in
{
  home.packages = [
    nixSearchScript
  ];

  xdg.configFile."aichat/functions/bin/nix_search".source =
    "${nixSearchScript}/bin/nix_search";
}

