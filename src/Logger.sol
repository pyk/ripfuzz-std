// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title Logger
///
/// @dev Logging utilities for ripfuzz harnesses. Provides a family of `Log`
///      events and overloaded `log` helpers.
abstract contract Logger {
    // [*] Events =============================================================

    /// @dev Log a string message.
    /// @param message The log message.
    event Log(string message);

    /// @dev Log a string message with a string value.
    /// @param message The log message.
    /// @param value The string value.
    event Log(string message, string value);

    /// @dev Log a string message with a uint256 value.
    /// @param message The log message.
    /// @param value The uint256 value.
    event Log(string message, uint256 value);

    /// @dev Log a string message with an address value.
    /// @param message The log message.
    /// @param value The address value.
    event Log(string message, address value);

    /// @dev Log a string message with a bytes value.
    /// @param message The log message.
    /// @param value The bytes value.
    event Log(string message, bytes value);

    /// @dev Log a string message with a bool value.
    /// @param message The log message.
    /// @param value The bool value.
    event Log(string message, bool value);

    // [*] Log helpers ========================================================

    /// @dev Emit a string log.
    /// @param message The log message.
    function log(string memory message) internal {
        emit Log(message);
    }

    /// @dev Emit a string log with a string value.
    /// @param message The log message.
    /// @param value The string value.
    function log(string memory message, string memory value) internal {
        emit Log(message, value);
    }

    /// @dev Emit a string log with a uint256 value.
    /// @param message The log message.
    /// @param value The uint256 value.
    function log(string memory message, uint256 value) internal {
        emit Log(message, value);
    }

    /// @dev Emit a string log with an address value.
    /// @param message The log message.
    /// @param value The address value.
    function log(string memory message, address value) internal {
        emit Log(message, value);
    }

    /// @dev Emit a string log with a bytes value.
    /// @param message The log message.
    /// @param value The bytes value.
    function log(string memory message, bytes memory value) internal {
        emit Log(message, value);
    }

    /// @dev Emit a string log with a bool value.
    /// @param message The log message.
    /// @param value The bool value.
    function log(string memory message, bool value) internal {
        emit Log(message, value);
    }
}
