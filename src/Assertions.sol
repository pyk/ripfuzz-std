// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Logger} from "./Logger.sol";

/// @title Assertions
///
/// @dev Assertion utilities for ripfuzz harnesses. Failures log a descriptive
///      message, then panic via `assert(false)`.
abstract contract Assertions is Logger {
    // [*] Control ============================================================

    /// @dev Assert that a code path is unreachable. Logs `message`, then
    ///      panics.
    /// @param message A descriptive message explaining why this path should be unreachable.
    function unreachable(string memory message) internal {
        log("[unreachable] ", message);
        assert(false);
    }

    /// @dev Assert that `condition` is true. On failure, logs `message` and
    ///      panics.
    /// @param condition The condition that must hold.
    /// @param message A descriptive message explaining the expected state.
    function ensure(bool condition, string memory message) internal {
        if (!condition) {
            log("[ensure failed] ", message);
            assert(false);
        }
    }

    // [*] eq =================================================================

    /// @dev Assert that two `uint256` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param message A descriptive message explaining the expected equality.
    function eq(uint256 a, uint256 b, string memory message) internal {
        if (a != b) {
            log("[eq failed] ", message);
            log("  a: ", a);
            log("  b: ", b);
            assert(false);
        }
    }

    /// @dev Assert that two `bytes32` values are equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param message A descriptive message explaining the expected equality.
    function eq(bytes32 a, bytes32 b, string memory message) internal {
        if (a != b) {
            log("[eq failed] ", message);
            log("  a: ", abi.encodePacked(a));
            log("  b: ", abi.encodePacked(b));
            assert(false);
        }
    }

    /// @dev Assert that two `address` values are equal.
    /// @param a The first address.
    /// @param b The second address.
    /// @param message A descriptive message explaining the expected equality.
    function eq(address a, address b, string memory message) internal {
        if (a != b) {
            log("[eq failed] ", message);
            log("  a: ", a);
            log("  b: ", b);
            assert(false);
        }
    }

    /// @dev Assert that two `bool` values are equal.
    /// @param a The first bool.
    /// @param b The second bool.
    /// @param message A descriptive message explaining the expected equality.
    function eq(bool a, bool b, string memory message) internal {
        if (a != b) {
            log("[eq failed] ", message);
            log("  a: ", a);
            log("  b: ", b);
            assert(false);
        }
    }

    // [*] neq ================================================================

    /// @dev Assert that two `uint256` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param message A descriptive message explaining the expected inequality.
    function neq(uint256 a, uint256 b, string memory message) internal {
        if (a == b) {
            log("[neq failed] ", message);
            log("  a: ", a);
            log("  b: ", b);
            assert(false);
        }
    }

    /// @dev Assert that two `bytes32` values are not equal.
    /// @param a The first value.
    /// @param b The second value.
    /// @param message A descriptive message explaining the expected inequality.
    function neq(bytes32 a, bytes32 b, string memory message) internal {
        if (a == b) {
            log("[neq failed] ", message);
            log("  a: ", abi.encodePacked(a));
            log("  b: ", abi.encodePacked(b));
            assert(false);
        }
    }

    /// @dev Assert that two `address` values are not equal.
    /// @param a The first address.
    /// @param b The second address.
    /// @param message A descriptive message explaining the expected inequality.
    function neq(address a, address b, string memory message) internal {
        if (a == b) {
            log("[neq failed] ", message);
            log("  a: ", a);
            log("  b: ", b);
            assert(false);
        }
    }

    /// @dev Assert that two `bool` values are not equal.
    /// @param a The first bool.
    /// @param b The second bool.
    /// @param message A descriptive message explaining the expected inequality.
    function neq(bool a, bool b, string memory message) internal {
        if (a == b) {
            log("[neq failed] ", message);
            log("  a: ", a);
            log("  b: ", b);
            assert(false);
        }
    }
}
