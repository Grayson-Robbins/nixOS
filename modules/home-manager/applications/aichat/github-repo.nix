
{ pkgs, ... }:

let
  githubRepoScript = pkgs.writeShellApplication {
    name = "github_repo";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];

    text = ''
      set -euo pipefail

      if [[ "$#" -ne 1 ]]; then
        echo "Usage: github_repo '<JSON arguments>'" >&2
        exit 2
      fi

      if [[ -z "''${LLM_OUTPUT:-}" ]]; then
        echo "LLM_OUTPUT must point to the tool output file." >&2
        exit 2
      fi

      input="$1"

      operation="$(jq -er '.operation | strings' <<< "$input")"
      repo="$(jq -r '.repo // "" | strings' <<< "$input")"
      query="$(jq -r '.query // "" | strings' <<< "$input")"
      limit="$(jq -r '.limit // 20' <<< "$input")"

      if ! [[ "$limit" =~ ^[0-9]+$ ]] || (( limit < 1 || limit > 100 )); then
        echo "limit must be an integer between 1 and 100." >&2
        exit 2
      fi

      case "$operation" in
        repository|releases|tags|commits|contributors|forks)
          if ! [[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
            echo "repo must use the owner/repository format." >&2
            exit 2
          fi

          case "$operation" in
            repository)
              endpoint="https://api.github.com/repos/$repo"
              ;;
            releases)
              endpoint="https://api.github.com/repos/$repo/releases"
              ;;
            tags)
              endpoint="https://api.github.com/repos/$repo/tags"
              ;;
            commits)
              endpoint="https://api.github.com/repos/$repo/commits"
              ;;
            contributors)
              endpoint="https://api.github.com/repos/$repo/contributors"
              ;;
            forks)
              endpoint="https://api.github.com/repos/$repo/forks"
              ;;
          esac
          ;;
        search_repositories)
          if [[ -z "$query" ]]; then
            echo "query is required for search_repositories." >&2
            exit 2
          fi
          endpoint="https://api.github.com/search/repositories"
          ;;
        *)
          echo "Unsupported operation: $operation" >&2
          exit 2
          ;;
      esac

      if [[ "$operation" == "repository" ]]; then
        response="$(
          curl --fail --silent --show-error \
            --connect-timeout 5 --max-time 30 \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "$endpoint"
        )"
      elif [[ "$operation" == "search_repositories" ]]; then
        response="$(
          curl --fail --silent --show-error \
            --connect-timeout 5 --max-time 30 \
            --get \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            --data-urlencode "q=$query" \
            --data-urlencode "per_page=$limit" \
            "$endpoint"
        )"
      else
        response="$(
          curl --fail --silent --show-error \
            --connect-timeout 5 --max-time 30 \
            --get \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            --data-urlencode "per_page=$limit" \
            "$endpoint"
        )"
      fi

      jq -e . <<< "$response" > /dev/null || {
        echo "GitHub returned invalid JSON." >&2
        exit 1
      }

      jq -c \
        --arg operation "$operation" \
        --arg repo "$repo" \
        --arg query "$query" '
        def repository_fields:
          {
            full_name,
            name,
            owner: .owner.login,
            description,
            html_url,
            homepage,
            language,
            default_branch,
            created_at,
            updated_at,
            pushed_at,
            archived,
            disabled,
            fork,
            forks_count,
            stargazers_count,
            watchers_count,
            open_issues_count,
            license: .license.spdx_id,
            topics
          };

        def release_fields:
          {
            name,
            tag_name,
            draft,
            prerelease,
            created_at,
            published_at,
            html_url,
            target_commitish,
          };

        def tag_fields:
          {
            name,
            commit_sha: .commit.sha,
            commit_url: .commit.url
          };

        def commit_fields:
          {
            sha,
            html_url,
            author: .commit.author.name,
            author_login: .author.login,
            date: .commit.author.date,
            message: .commit.message
          };

        def contributor_fields:
          {
            login,
            html_url,
            contributions
          };

        def fork_fields:
          {
            full_name,
            owner: .owner.login,
            html_url,
            description,
            created_at,
            updated_at,
            pushed_at,
            stargazers_count,
            default_branch
          };

        {
          operation: $operation,
          repository: $repo,
          query: $query,
          data:
            if $operation == "repository" then
              repository_fields
            elif $operation == "search_repositories" then
              {
                total_count,
                incomplete_results,
                items: [
                  .items[] | repository_fields
                ]
              }
            elif $operation == "releases" then
              [ .[] | release_fields ]
            elif $operation == "tags" then
              [ .[] | tag_fields ]
            elif $operation == "commits" then
              [ .[] | commit_fields ]
            elif $operation == "contributors" then
              [ .[] | contributor_fields ]
            elif $operation == "forks" then
              [ .[] | fork_fields ]
            else
              .
            end,
          notes: [
            "Data is retrieved from the GitHub public REST API.",
            "List operations are limited to the requested first page.",
            "A commit is not necessarily a release.",
            "Fork existence does not establish that it is actively maintained.",
            "Use the returned URLs and timestamps as supplied; do not infer missing activity."
          ]
        }
      ' <<< "$response" >> "$LLM_OUTPUT"
    '';
  };

in
{
  home.packages = [
    githubRepoScript
  ];

  xdg.configFile."aichat/functions/bin/github_repo".source =
    "${githubRepoScript}/bin/github_repo";
}

