
{ config, lib, pkgs, ... }:

let
  webSearchScript = pkgs.writeShellApplication {
    name = "web_search";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];

    text = ''
      set -euo pipefail

      if [[ "$#" -ne 1 ]]; then
        echo "Usage: web_search '<JSON arguments>'" >&2
        exit 2
      fi

      if [[ -z "''${LLM_OUTPUT:-}" ]]; then
        echo "LLM_OUTPUT must point to the tool output file." >&2
        exit 2
      fi

      input="$1"

      query="$(jq -er '
        .query
        | strings
        | gsub("^\\s+|\\s+$"; "")
        | select(length > 0)
      ' <<< "$input")" || {
        echo "A non-empty query string is required." >&2
        exit 2
      }

      validate_domains() {
        local field="$1"

        jq -ce --arg field "$field" '
          .[$field] // []
          | if type != "array" then
              error($field + " must be an array of domain strings")
            else
              map(
                if type != "string" then
                  error($field + " entries must be strings")
                elif (
                  test("^[A-Za-z0-9.-]+$")
                  and (contains("..") | not)
                  and (test("^\\.") | not)
                  and (test("\\.$") | not)
                  and (test("(^-|-$)") | not)
                ) then
                  ascii_downcase
                else
                  error("Invalid domain in " + $field)
                end
              )
              | unique
            end
        ' <<< "$input"
      }

      domains_json="$(validate_domains "domains")"
      exclude_domains_json="$(validate_domains "exclude_domains")"

      domain_filter="$(
        jq -r '
          if length == 0 then
            ""
          else
            map("site:" + .)
            | join(" OR ")
            | "(" + . + ")"
          end
        ' <<< "$domains_json"
      )"

      exclude_filter="$(
        jq -r '
          map("-site:" + .)
          | join(" ")
        ' <<< "$exclude_domains_json"
      )"

      search_query="$query"

      if [[ -n "$domain_filter" ]]; then
        search_query="$search_query $domain_filter"
      fi

      if [[ -n "$exclude_filter" ]]; then
        search_query="$search_query $exclude_filter"
      fi

      response="$(
        curl \
          --fail \
          --silent \
          --show-error \
          --connect-timeout 3 \
          --max-time 30 \
          --get \
          --data-urlencode "q=$search_query" \
          --data-urlencode "format=json" \
          "http://127.0.0.1:8888/search"
      )"

      jq -e '(.results | type) == "array"' \
        <<< "$response" > /dev/null || {
        echo "SearXNG returned an invalid response." >&2
        exit 1
      }

      as_of="$(date +%Y-%m-%d)"

      jq -c \
        --arg query "$query" \
        --arg as_of "$as_of" \
        --argjson requested_domains "$domains_json" \
        --argjson excluded_domains "$exclude_domains_json" '
          def matches_domain($host; $domain):
            $host == $domain
            or ($host | endswith("." + $domain));

          [
            .results[]
            | . as $result
            | (($result.parsed_url[1] // "") | ascii_downcase) as $host

            # Reject results without a usable parsed hostname.
            | select($host != "")

            # Enforce the allowlist, including legitimate subdomains.
            | select(
                ($requested_domains | length) == 0
                or any(
                  $requested_domains[];
                  matches_domain($host; .)
                )
              )

            # Enforce the blocklist, including subdomains.
            | select(
                all(
                  $excluded_domains[];
                  (matches_domain($host; .) | not)
                )
              )

            # Reject malformed or unsupported result URLs.
            | select(
                ($result.url // "") != ""
                and (
                  ($result.url | startswith("https://"))
                  or ($result.url | startswith("http://"))
                )
              )

            | {
                title: ($result.title // ""),
                url: $result.url,
                domain: $host,
                content: (($result.content // "")[0:1200]),
                engine: ($result.engine // null),
                published_date: ($result.publishedDate // null),
                score: ($result.score // null)
              }
          ]
          | .[:10] as $results
          | {
              as_of: $as_of,
              query: $query,
              requested_domains: $requested_domains,
              excluded_domains: $excluded_domains,
              result_count: ($results | length),
              results: $results,
              notes: [
                "Domain restrictions are enforced locally against parsed result hostnames.",
                "Allowlisted domains include their subdomains.",
                "Blocked domains also exclude their subdomains.",
                "Search-engine site operators are best-effort hints; local filtering determines which results are returned.",
                "A zero-result response means no results satisfied the requested domain restrictions.",
                "URLs are copied from SearXNG and must not be reconstructed."
              ]
            }
        ' <<< "$response" >> "$LLM_OUTPUT"
    '';
  };

in
{

  home.packages = [
    webSearchScript
  ];

  xdg.configFile."aichat/functions/bin/web_search".source =
    "${webSearchScript}/bin/web_search";
}

