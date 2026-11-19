# nixOS/modules/home-manager/applications/aichat/functions.nix
[
  {
    name = "web_search";

    description = ''
      Search the web using the local SearXNG instance.

      Use for general web research, source discovery, current information,
      technical documentation, troubleshooting, and information not
      available through specialized tools.

      QUERY CONSTRUCTION:
      - Use specific queries identifying the exact product, project,
        repository, organization, version, or person.
      - Do not use vague follow-up queries such as "the fork mentioned".
      - Carry forward repository owners, project names, URLs, and
        discussion context from earlier results.

      SOURCE RESTRICTIONS:
      - domains is an allowlist; exclude_domains is a blocklist.
      - Apply both restrictions when requested.
      - Domain filtering includes subdomains.
      - Restrictions apply to returned results, not necessarily to
        upstream search-engine retrieval.
      - Domain filters cannot distinguish page types on the same domain.

      FACTUAL VERIFICATION:
      - Prefer official documentation, release announcements, and
        primary sources.
      - Treat search results as leads, not necessarily complete answers.
      - Distinguish publication dates, release dates, commit dates,
        discussion dates, and last-modified dates.
      - Do not infer active maintenance, abandonment, or upcoming
        releases without evidence.
      - Never invent names, dates, versions, or URLs.
      - Clearly identify uncertainty and conflicting evidence.

      SOFTWARE RESEARCH:
      - Distinguish releases, prereleases, tags, commits, pull requests,
        issues, and discussions.
      - Do not treat the latest commit or discussion as the latest release.
      - Use github_repo for structured GitHub repository information.

      OUTPUT:
      - Use exact URLs returned by this tool.
      - Do not reconstruct or guess URLs.
      - Support factual claims with the returned sources.
    '';

    parameters = {
      type = "object";
      properties = {
        query = {
          type = "string";
          description = "Specific web search query.";
        };

        domains = {
          type = "array";
          description = "Optional domain allowlist, including subdomains.";
          items = {
            type = "string";
          };
        };

        exclude_domains = {
          type = "array";
          description = "Optional domain blocklist, including subdomains.";
          items = {
            type = "string";
          };
        };
      };

      required = [ "query" ];
      additionalProperties = false;
    };
  }

  {
    name = "github_repo";

    description = ''
      Retrieve structured information from GitHub's public REST API.

      OPERATIONS:
      - repository: repository metadata.
      - releases: published releases.
      - tags: repository tags.
      - commits: recent commits.
      - contributors: contributor activity.
      - forks: repository forks.
      - search_repositories: search GitHub repositories.

      RESEARCH RULES:
      - Identify the exact owner/repository before investigating it.
      - Preserve repository owner and full name in follow-up research.
      - Do not assume two repositories or forks are related without
        evidence establishing the relationship.
      - Distinguish releases, tags, commits, and repository activity.
      - A commit or tag is not necessarily a release.
      - Do not infer that a fork is active or maintained from its existence.
      - Use returned timestamps and URLs exactly as provided.
      - For fork investigations, inspect the fork's own metadata,
        releases, commits, and contributors as appropriate.
      - List operations return only the requested first page.
      - Public unauthenticated GitHub API rate limits apply.
      OPTION CLASSIFICATION:
      - Always classify each option using its returned `type` and`option_source`, not the requested operation.
      - A result returned by `nixos_options` is not necessarily a NixOS option.
      - A result with type `home-manager-option` must be identified as a Home Manager option, even if returned by a NixOS-scoped search.
      - Explicitly flag disagreements between the requested scope, returned type, and source.
      - Never silently reclassify an option to make it fit the search scope.
      RELEASE OUTPUT:
      - The releases operation returns compact release metadata, not changelog bodies.
      - Use tag_name as the release identifier.
      - Use published_at as the publication date.
      - Use html_url as the release URL.
      - When asked for recent releases, return the requested number of releases in the order supplied by the tool.
      - Do not substitute tags or commits for releases.
      - Do not invent missing release metadata.
      COMMIT OUTPUT:
      - author is the name recorded in the Git commit.
      - author_login is the associated GitHub account username.
      - Never combine these fields or include both unless explicitly requested.
      - When a short commit SHA is requested, display only the first 7 characters of sha. Preserve the full SHA internally for URLs.
      - Produce a valid Markdown table with exactly one header row, one separator row, and one row per result.
      - Do not place table rows before the separator row.
      - Do not append empty columns or trailing pipe delimiters.
    '';

    parameters = {
      type = "object";
      properties = {
        operation = {
          type = "string";
          enum = [
            "repository"
            "releases"
            "tags"
            "commits"
            "contributors"
            "forks"
            "search_repositories"
          ];
          description = "GitHub API operation.";
        };

        repo = {
          type = "string";
          description = "Repository in owner/repository format.";
        };

        query = {
          type = "string";
          description = "GitHub repository search query.";
        };

        limit = {
          type = "integer";
          minimum = 1;
          maximum = 100;
          description = "Maximum results. Defaults to 20.";
        };
      };

      required = [ "operation" ];
      additionalProperties = false;
    };
  }

  {
    name = "nix_search";

    description = ''
      Search Nix packages and NixOS or Home Manager options using nh.

      OPERATIONS:
      - packages: search Nixpkgs packages.
      - nixos_options: search NixOS module options.
      - home_manager_options: search Home Manager options.
      - all_options: search across supported option scopes.

      RESEARCH RULES:
      - Use home_manager_options for Home Manager settings.
      - Use nixos_options for system-level NixOS settings.
      - Use all_options when the correct scope is uncertain.
      - Use packages for package names, versions, descriptions,
        platforms, and package metadata.
      - Preserve the selected channel when comparing results.
      - Package availability does not establish that a package is installed.
      - Option definitions and defaults do not establish the evaluated
        value in the user's configuration.
      - Do not confuse package installation with feature enablement.
      - This tool does not search arbitrary third-party flakes.
      - For third-party flake research, identify the repository and
        inspect its documented outputs and source separately.
    '';

    parameters = {
      type = "object";
      properties = {
        operation = {
          type = "string";
          enum = [
            "packages"
            "nixos_options"
            "home_manager_options"
            "all_options"
          ];
          description = "Nix search operation.";
        };

        query = {
          type = "string";
          description = "Package name or option search query.";
        };

        channel = {
          type = "string";
          description = "Nix channel. Defaults to nixos-unstable.";
        };

        limit = {
          type = "integer";
          minimum = 1;
          maximum = 100;
          description = "Maximum package results. Defaults to 30.";
        };
      };

      required = [
        "operation"
        "query"
      ];

      additionalProperties = false;
    };
  }
]

