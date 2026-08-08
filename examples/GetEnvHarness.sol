// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title GetEnvHarness
///
/// @dev Example of reading environment variables with `rvm.getEnv`, including
///      values loaded from a project `.env` file.
contract GetEnvHarness is Harness {
    /// @dev Value of `NETWORK`, or `"local"` when unset.
    string internal network;

    /// @dev Value loaded with an explicit default for a missing key.
    string internal missingDefaulted;

    /// @dev Load env values used by later invariants.
    function setup() external {
        // Optional override via `.env`:
        // NETWORK=mainnet
        network = rvm.getEnv("NETWORK", "local");

        // Unique key so the default path is stable in smoke tests.
        missingDefaulted = rvm.getEnv("RIPFUZZ_STD_GETENV_MISSING", "fallback");
    }

    /// @dev No-op handler so the campaign has something to call.
    function ping() external {
        log("network", network);
        log("missingDefaulted", missingDefaulted);
    }

    /// @dev Invariant: defaulted env lookup returns the provided default.
    function invariant_MissingKeyUsesDefault() external {
        ensure(keccak256(bytes(missingDefaulted)) == keccak256(bytes("fallback")), "missing key uses default");
    }

    /// @dev Invariant: network string is non-empty.
    function invariant_NetworkNonEmpty() external {
        ensure(bytes(network).length > 0, "network is non-empty");
    }
}
