# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.6] - 2026-07-29

### Fixed

- NaughtyWords: removed `ناجائز` and `نجائز` from the Urdu-script list. Both are
  ordinary non-profane words meaning invalid/illegitimate, so matching them
  produced false positives on benign text ([#2]).

## [2.1.5] - 2026-06-22

### Fixed

- NaughtyWords: Urdu-script gaaliyan now match on word boundaries, removing
  false positives where a banned token appeared as a substring of a larger,
  benign Urdu word ([#1]).

## [2.1.4]

- Previous release. See git history for details.

[2.1.6]: https://github.com/AbdulRehhman/despamilator-elixir/releases/tag/v2.1.6
[2.1.5]: https://github.com/AbdulRehhman/despamilator-elixir/releases/tag/v2.1.5
[2.1.4]: https://github.com/AbdulRehhman/despamilator-elixir/releases/tag/v2.1.4
[#1]: https://github.com/AbdulRehhman/despamilator-elixir/pull/1
[#2]: https://github.com/AbdulRehhman/despamilator-elixir/pull/2
