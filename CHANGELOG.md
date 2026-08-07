# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

- `Harness` abstract base contract with the ripfuzz VM bound at the Foundry
  HEVM address:

  ```solidity
  // 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
  address internal constant RVM_ADDRESS =
      address(uint160(uint256(keccak256("hevm cheat code"))));

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

### Changed

### Fixed
