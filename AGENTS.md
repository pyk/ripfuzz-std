# Ripfuzz Standard Library

Project conventions for `ripfuzz-std`. Follow these rules when editing Solidity
sources in this repository.

## Non-negotiable rules

### General

- You must keep the public import remapping as `ripfuzz/=src/`.
- You must run `make fmt` before finishing if sources need formatting.
- You must run `make lint` after Solidity changes.
- You must run `make test` after harness or example changes.
- You must not use em dash characters in code, comments, or markdown.

### Layout

- You must put interfaces under `src/interfaces/`.
- You must put libraries under `src/libraries/`.
- You must keep abstract base contracts and the RVM interface at `src/` root.
- You must put example harnesses under `examples/` (Foundry
  `test = "examples"`).
- You must use `pragma solidity >=0.8.0 <0.9.0;`.
- You must use `// SPDX-License-Identifier: MIT` and no per-file copyright
  headers.

## NatSpec style

Match `src/RVM.sol`. Prefer short `@dev` docs over `@notice`.

### File / type header

```solidity
/// @title TypeName
///
/// @dev One or more sentences describing the type. Continuation lines are
///      indented to align under the first content character after `@dev `.
```

Rules:

- You must use `@title` for the type name.
- You must put a blank `///` line between `@title` and `@dev`.
- You must document the type with `@dev`, not `@notice`.
- You must wrap long lines. Continuation lines use `///` so text aligns under
  the first character after `@dev`.

### Members (functions, events, errors, structs, fields)

```solidity
/// @dev Set `block.timestamp`.
/// @param newTimestamp The new block timestamp.
function warp(uint256 newTimestamp) external;

/// @dev Get the nonce of `account`.
/// @param account The account to query.
/// @return The account nonce.
function getNonce(address account) external view returns (uint256);
```

Rules:

- You must document members with `@dev` for the behavior summary.
- You must not use `@notice` on members.
- You must use `@param` for each parameter when the member has parameters.
- You must use `@return` for each return value when the member returns values.
- You must reference identifiers in `@dev` with backticks: `` `account` ``,
  `` `value` ``, `` `msg.sender` ``.
- You must write short imperative or descriptive `@dev` sentences (`Set ...`,
  `Return ...`, `Assert ...`, `Bound ...`).
- You may use a second `@dev` paragraph only when extra behavior needs a
  separate sentence group. Prefer one compact `@dev` block.

### Section banners

Group related members with fixed-width section banners:

```solidity
// [*] Block ==============================================================
```

Rules:

- You must use the form `// [*] {Name} {=...}` with a single space between the
  name and the first `=`.
- You must pad with `=` so the full line is 75 characters.
- You must place a blank line after each banner, before the first member.
- You must place a blank line before each banner (except when it is the first
  content inside a type body).
- You should name sections after domain concepts (`Events`, `eq`, `Permit`),
  not implementation details.

### Inline comments

- You may use short `//` comments for non-obvious implementation notes.
- You must not restate the NatSpec in an inline comment.
- You must not use decorative banners other than the `// [*] ...` form above.

## Inheritance and API shape

- Libraries such as `Bound` and `SafeERC20` must remain usable without
  inheriting `Harness`.
- Prefer adding shared harness helpers to `Harness` only when most harnesses
  need them. Otherwise keep them as libraries under `src/libraries/`.

## Docs

- You must update `CHANGELOG.md` under `[Unreleased]` for user-visible API
  changes.
- You must update `README.md` when install steps, import paths, or example
  usage change.

### Changelog

Follow Keep a Changelog and Semantic Versioning.

- You must record user-visible changes under `## [Unreleased]`.

- You must use the subsections `### Added`, `### Changed`, and `### Fixed`
  under `[Unreleased]` (leave a subsection empty when unused).

- When preparing a release, you must move `[Unreleased]` entries into a new
  versioned section `## [X.Y.Z] - YYYY-MM-DD`.

- After cutting a release section, you must keep an empty `[Unreleased]`
  section at the top with `### Added`, `### Changed`, and `### Fixed` ready for
  future entries:

  ```md
  ## [Unreleased]

  ### Added

  ### Changed

  ### Fixed

  ## [X.Y.Z] - YYYY-MM-DD
  ```

- You must update the comparison links at the bottom of `CHANGELOG.md` when
  adding a new version section.
