# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

### Fixed

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

[unreleased]: https://github.com/pyk/ripfuzz-std/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/pyk/ripfuzz-std/releases/tag/v1.0.0
