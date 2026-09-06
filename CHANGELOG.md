# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Invariant` struct with `id` and `description` fields.

- `BrokenInvariantError` custom error on `InvariantTest`. A handler or
  `invariant_*` call that reverts with it is recorded as a broken invariant by
  id and description.

- `InvariantTest` base contract with `createInvariant` handles and checks
  (`ensure`, `eq`, `neq`, `gt`, `gte`, `lt`, `lte`) that report through
  `BrokenInvariantError`.

- `Script` base contract for `ripfuzz exec` scripts with `rvm` and `log`.

- `Deal` library with a foundry-style ERC20 `deal`. Probes the `balanceOf`
  mapping slot with `rvm.store` and `rvm.load` and writes the new balance to
  storage. Supports Solidity and Vyper mapping layouts, exposes
  `findBalanceSlot` for probing the slot once, and a `deal` slot form for
  repeated deals on the same token.

- `deal` helpers on `Base`: `deal(account, value)` for ether and
  `deal(token, account, value)` for ERC20 tokens, available on scripts and
  harnesses without an import. Token balance slots are probed once and cached
  per token.

- `fork` and `label` helpers on `Base`, wrapping the matching `rvm` cheatcodes
  so scripts and harnesses can call them without the prefix.

- `Base` base contract providing the shared `rvm` cheatcode interface.

- `std.sol` entrypoint re-exporting the standard library.

- End-to-end invariant testing example at `examples/ExampleInvariantTest.sol`
  with a target contract, setup, handlers, and invariant handles.

- End-to-end script example at `examples/ExampleScript.sol`.

- End-to-end deal example at `examples/ExampleDeal.sol` that deals ether, WETH
  (Solidity layout), and CRV (Vyper layout) to a labeled account on a pinned
  mainnet fork, run by `make exec`.

- End-to-end max mode example at `examples/ExampleMax.sol` with a rewards
  accumulator and a `value()` function measuring the highest pending reward.

- `Layout.Solady` in the `Deal` library. The balance probe covers Solady ERC20
  unstructured balances (`keccak256` of the owner and the fixed balance seed),
  so `deal` works on Solady-based tokens whose mapping sits outside the
  sequential slot range.

- `make max` target with a `MAXES` list for max mode smoke tests.

### Changed

- `ExampleScript` funds its labeled account with the `deal` helper instead of
  `rvm.deal`.

- Removed `Assertions` and its string-message checks (`ensure`, `eq`, `neq`,
  `unreachable`). Use the `InvariantTest` checks instead.

### Fixed

## [1.3.0] - 2026-08-21

### Added

- `IWETH` interface with `deposit` and `withdraw`.

- `IERC20.transfer` and `IERC20.transferFrom`.

- `createAddress(string)` helper: derives an address from `keccak256(name)`,
  labels it, and returns it.

- `createAddressAndKey(string)` helper: same as `createAddress`, and also
  returns the private key.

- Actor helpers on `Harness` for multi-user harnesses:

  - `useActor(actorId)` modifier pranks as a fuzz-selected actor
  - `addActor`, `removeActor`, `getActor`, `actorCount`
  - `addActor(string)` stores a recoverable private key
  - `currentActor` tracks the active `useActor` selection

- Example harnesses under `examples/` for each Usage feature, including:
  - `ForkHarness` for mainnet USDC
  - `MultiForkHarness` for Ethereum + Base USDC forks

## [1.2.0] - 2026-08-08

### Added

- Harness helpers for writing ripfuzz fuzz tests:

  | Module       | Purpose                                                |
  | ------------ | ------------------------------------------------------ |
  | `Logger`     | `log(...)` helpers via overloaded `Log` events         |
  | `Assertions` | `ensure`, `eq`, `neq`, `unreachable` with failure logs |
  | `Bound`      | Clamp a `uint256` into an inclusive `[min, max]` range |
  | `SafeERC20`  | Safe `approve` / `transfer` for non-standard ERC20s    |
  | `IERC20`     | Minimal ERC20 + metadata + EIP-2612 permit interface   |

- `Harness` now inherits `Assertions` (and therefore `Logger`) and exposes
  `bound(uint256,uint256,uint256)` so harnesses get logging, assertions, and
  input clamping without extra imports.

- Example harness at `examples/CounterHarness.sol`, run by `make test`.

- Library and interface import paths:

  ```solidity
  import {Bound} from "ripfuzz/libraries/Bound.sol";
  import {SafeERC20} from "ripfuzz/libraries/SafeERC20.sol";
  import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
  ```

## [1.1.0] - 2026-08-07

### Added

- `rvm.fork` cheatcode bindings to create or select a remote chain fork:

  ```solidity
  struct ForkConfig {
      uint32 retries;
      uint64 backoffMs;
      uint64 timeoutMs;
      uint64 rateLimit;
  }

  function fork(string calldata url, uint256 blockNumber) external;
  function fork(string calldata url, uint256 blockNumber, ForkConfig config)
      external;
  ```

### Changed

- RVM address is now derived from `keccak256("ripfuzz cheatcode")` instead of
  Foundry's `hevm cheat code`:

  ```text
  0x628dC59F11F72B611132eC40437F125ba1312F08
  ```

## [1.0.0] - 2026-08-07

Initial public release

### Added

- `RVM` interface covering the full ripfuzz cheatcode surface:

  | Category            | Cheatcodes                                                                                     |
  | ------------------- | ---------------------------------------------------------------------------------------------- |
  | Block               | `warp`, `roll`, `fee`, `coinbase`, `prevrandao`, `chainId`                                     |
  | Account             | `deal`, `etch`, `setNonce`, `getNonce`, `store`, `load`                                        |
  | Prank               | `prank`, `startPrank`, `stopPrank`                                                             |
  | Label               | `label`, `getLabel`                                                                            |
  | Conversion          | `toString`, `parseUint`, `parseInt`, `parseBool`, `parseAddress`, `parseBytes`, `parseBytes32` |
  | Code / wallet / ffi | `getCode`, `addr`, `sign`, `ffi`                                                               |
  | Environment         | `getEnv`                                                                                       |

- `Harness` abstract base contract with the ripfuzz VM bound at the RVM
  address:

  ```solidity
  // 0x628dC59F11F72B611132eC40437F125ba1312F08
  address internal constant RVM_ADDRESS =
      address(uint160(uint256(keccak256("ripfuzz cheatcode"))));

  RVM internal constant rvm = RVM(RVM_ADDRESS);
  ```

- `rvm.getEnv` cheatcode bindings to read environment variables as strings:

  ```solidity
  function getEnv(string calldata key) external returns (string memory value);
  function getEnv(string calldata key, string calldata defaultValue)
      external
      returns (string memory value);
  ```

  The single-argument form reverts when the key is missing. The two-argument
  form returns `defaultValue` when the key is missing.

- `ripfuzz/` import remapping so consumers can write:

  ```solidity
  import {Harness} from "ripfuzz/Harness.sol";
  ```

[unreleased]: https://github.com/pyk/ripfuzz-std/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/pyk/ripfuzz-std/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/pyk/ripfuzz-std/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/pyk/ripfuzz-std/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/pyk/ripfuzz-std/releases/tag/v1.0.0
