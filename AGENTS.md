# Ripfuzz Standard Library

Project conventions for `ripfuzz-std`. Follow these rules when editing Solidity
sources in this repository.

## Non-negotiable rules

List of CRITICAL rules that you must follow every time. Failing to do so will
have a severe negative impact on the project and the user.

### General Rules

| ID     | Rule                                                            |
| :----- | :-------------------------------------------------------------- |
| GEN-01 | MUST keep the public import remapping as `ripfuzz/=src/`        |
| GEN-02 | MUST run `make fmt` before finishing if sources need formatting |
| GEN-03 | MUST run `make lint` after Solidity changes                     |
| GEN-04 | MUST run `make test` after harness or example changes           |
| GEN-05 | MUST NOT use em dash characters in code, comments, or markdown  |

### Layout Rules

| ID        | Rule                                                                                   |
| :-------- | :------------------------------------------------------------------------------------- |
| LAYOUT-01 | MUST put interfaces under `src/interfaces/`                                            |
| LAYOUT-02 | MUST put libraries under `src/libraries/`                                              |
| LAYOUT-03 | MUST keep abstract base contracts and the RVM interface at `src/` root                 |
| LAYOUT-04 | MUST put example harnesses under `examples/` (Foundry `test = "examples"`)             |
| LAYOUT-05 | MUST use `pragma solidity >=0.8.0 <0.9.0;`                                             |
| LAYOUT-06 | MUST use `// SPDX-License-Identifier: MIT` and MUST NOT add per-file copyright headers |

### NatSpec Rules

Match `src/RVM.sol`. Prefer short `@dev` docs over `@notice`.

File / type header:

```solidity
/// @title TypeName
///
/// @dev One or more sentences describing the type. Continuation lines are
///      indented to align under the first content character after `@dev `.
```

Members (functions, events, errors, structs, fields):

```solidity
/// @dev Set `block.timestamp`.
/// @param newTimestamp The new block timestamp.
function warp(uint256 newTimestamp) external;

/// @dev Get the nonce of `account`.
/// @param account The account to query.
/// @return The account nonce.
function getNonce(address account) external view returns (uint256);
```

| ID         | Rule                                                                                                                        |
| :--------- | :-------------------------------------------------------------------------------------------------------------------------- |
| NATSPEC-01 | MUST use `@title` for the type name                                                                                         |
| NATSPEC-02 | MUST put a blank `///` line between `@title` and `@dev`                                                                     |
| NATSPEC-03 | MUST document the type with `@dev`, not `@notice`                                                                           |
| NATSPEC-04 | MUST wrap long lines. Continuation lines use `///` so text aligns under the first character after `@dev`                    |
| NATSPEC-05 | MUST document members with `@dev` for the behavior summary                                                                  |
| NATSPEC-06 | MUST NOT use `@notice` on members                                                                                           |
| NATSPEC-07 | MUST use `@param` for each parameter when the member has parameters                                                         |
| NATSPEC-08 | MUST use `@return` for each return value when the member returns values                                                     |
| NATSPEC-09 | MUST reference identifiers in `@dev` with backticks: `` `account` ``, `` `value` ``, `` `msg.sender` ``                     |
| NATSPEC-10 | MUST write short imperative or descriptive `@dev` sentences (`Set ...`, `Return ...`, `Assert ...`, `Bound ...`)            |
| NATSPEC-11 | MAY use a second `@dev` paragraph only when extra behavior needs a separate sentence group. Prefer one compact `@dev` block |

### Section Banner Rules

Group related members with fixed-width section banners:

```solidity
// [*] Block ==============================================================
```

| ID        | Rule                                                                                                |
| :-------- | :-------------------------------------------------------------------------------------------------- |
| BANNER-01 | MUST use the form `// [*] {Name} {=...}` with a single space between the name and the first `=`     |
| BANNER-02 | MUST pad with `=` so the full line is 75 characters                                                 |
| BANNER-03 | MUST place a blank line after each banner, before the first member                                  |
| BANNER-04 | MUST place a blank line before each banner (except when it is the first content inside a type body) |
| BANNER-05 | SHOULD name sections after domain concepts (`Events`, `eq`, `Permit`), not implementation details   |

### Inline Comment Rules

| ID         | Rule                                                                   |
| :--------- | :--------------------------------------------------------------------- |
| COMMENT-01 | MAY use short `//` comments for non-obvious implementation notes       |
| COMMENT-02 | MUST NOT restate the NatSpec in an inline comment                      |
| COMMENT-03 | MUST NOT use decorative banners other than the `// [*] ...` form above |

### API Rules

| ID     | Rule                                                                                                                                     |
| :----- | :--------------------------------------------------------------------------------------------------------------------------------------- |
| API-01 | MUST keep libraries such as `Bound` and `SafeERC20` usable without inheriting `Harness`                                                  |
| API-02 | MUST add shared harness helpers to `Harness` only when most harnesses need them. Otherwise keep them as libraries under `src/libraries/` |

### Docs Rules

| ID      | Rule                                                                                                                                                   |
| :------ | :----------------------------------------------------------------------------------------------------------------------------------------------------- |
| DOCS-01 | MUST update `CHANGELOG.md` under `[Unreleased]` for user-visible API changes                                                                           |
| DOCS-02 | MUST update `README.md` when install steps, import paths, or public usage change                                                                       |
| DOCS-03 | MUST document new user-facing helpers under the README `## Usage` section as a dedicated subsection                                                    |
| DOCS-04 | MUST add a focused example harness at `examples/{Feature}Harness.sol` for each Usage subsection, and wire it into the `HARNESSES` list in the Makefile |
| DOCS-05 | MUST keep `examples/CounterHarness.sol` as a small end-to-end smoke harness. Prefer realistic, minimal coverage over showcasing the full API surface   |

### Changelog Rules

| ID        | Rule                                                                                                                             |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------- |
| CHANGE-01 | MUST follow Keep a Changelog and Semantic Versioning                                                                             |
| CHANGE-02 | MUST record user-visible changes under `## [Unreleased]`                                                                         |
| CHANGE-03 | MUST use the subsections `### Added`, `### Changed`, and `### Fixed` under `[Unreleased]` (leave a subsection empty when unused) |
| CHANGE-04 | MUST move `[Unreleased]` entries into a new versioned section `## [X.Y.Z] - YYYY-MM-DD` when preparing a release                 |
| CHANGE-05 | MUST keep an empty `[Unreleased]` section at the top with `### Added`, `### Changed`, and `### Fixed` after cutting a release    |
| CHANGE-06 | MUST update the comparison links at the bottom of `CHANGELOG.md` when adding a new version section                               |

After cutting a release section, the empty `[Unreleased]` block MUST look like:

```md
## [Unreleased]

### Added

### Changed

### Fixed

## [X.Y.Z] - YYYY-MM-DD
```

### Commit Rules

| ID        | Rule                                                                                                                                  |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| COMMIT-01 | MUST write commit messages in Conventional Commits format: `<type>(<scope>): <subject>` (e.g. `feat(std): ...`, `chore(agents): ...`) |
| COMMIT-02 | MUST keep the subject compact: lower-case after the colon, no trailing period, and wrapped to about 72 columns                        |
| COMMIT-03 | MUST add a wrapped body paragraph (about 72 columns) explaining the why for non-trivial changes; skip the body for trivial changes    |
| COMMIT-04 | MUST NOT create a commit unless the user explicitly asks for one                                                                      |
| COMMIT-05 | MUST stop and ask the user when a commit surfaces an interactive prompt (e.g. a GPG passphrase)                                       |
| COMMIT-06 | MUST NOT type a passphrase or other secret into an interactive commit prompt                                                          |
| COMMIT-07 | MUST NOT bypass signing to force the commit through with `-c commit.gpgsign=false`                                                    |

## Tool References

### make

1. Format sources: `make fmt`
2. Check format and compile: `make lint`
3. Run example harness smoke tests: `make test`

For example:

```sh
# Format Solidity and markdown
make fmt

# Check foundry formatter and compile sources
make lint

# Run example harness smoke tests with ripfuzz
make test
```
