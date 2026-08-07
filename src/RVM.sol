// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title Ripfuzz Virtual Machine
///
/// @dev The ripfuzz VM is not fully Foundry-compatible. It implements only the
///      cheatcode subset supported by ripfuzz.
interface RVM {
    // [*] Block ==============================================================

    /// @dev Set `block.timestamp`.
    function warp(uint256 newTimestamp) external;

    /// @dev Set `block.number`.
    function roll(uint256 newNumber) external;

    /// @dev Set `block.basefee`.
    function fee(uint256 newBasefee) external;

    /// @dev Set `block.coinbase`.
    function coinbase(address newCoinbase) external;

    /// @dev Set `block.prevrandao`.
    function prevrandao(bytes32 newPrevrandao) external;

    /// @dev Set `block.chainid`.
    function chainId(uint256 newChainId) external;

    // [*] Account ============================================================

    /// @dev Set the ether balance of `account` to `value`.
    function deal(address account, uint256 value) external;

    /// @dev Set the bytecode of `account` to `code`.
    function etch(address account, bytes calldata code) external;

    /// @dev Set the nonce of `account`. Reverts if `nonce` is lower than current.
    function setNonce(address account, uint64 nonce) external;

    /// @dev Get the nonce of `account`.
    function getNonce(address account) external view returns (uint256);

    /// @dev Write `value` to storage `slot` of `account`.
    function store(address account, bytes32 slot, bytes32 value) external;

    /// @dev Read storage `slot` of `account`.
    function load(address account, bytes32 slot) external view returns (bytes32);

    // [*] Prank ==============================================================

    /// @dev Set `msg.sender` for the next call.
    function prank(address msgSender) external;

    /// @dev Set `msg.sender` and `tx.origin` for the next call.
    function prank(address msgSender, address txOrigin) external;

    /// @dev Set `msg.sender` for all subsequent calls until `stopPrank`.
    function startPrank(address msgSender) external;

    /// @dev Set `msg.sender` and `tx.origin` for all subsequent calls until
    /// `stopPrank`.
    function startPrank(address msgSender, address txOrigin) external;

    /// @dev Stop an active prank started with `startPrank`.
    function stopPrank() external;

    // [*] Label ==============================================================

    /// @dev Label `account` for clearer traces and logs.
    function label(address account, string calldata name) external;

    /// @dev Get the label previously set for `account`.
    function getLabel(address account) external view returns (string memory);

    // [*] Conversion =========================================================

    /// @dev Convert `value` to its string representation.
    function toString(address value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    function toString(bool value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    function toString(uint256 value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    function toString(int256 value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    function toString(bytes32 value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    function toString(bytes calldata value) external pure returns (string memory);

    /// @dev Parse `stringifiedValue` as a `uint256`.
    function parseUint(string calldata stringifiedValue) external pure returns (uint256);

    /// @dev Parse `stringifiedValue` as an `int256`.
    function parseInt(string calldata stringifiedValue) external pure returns (int256);

    /// @dev Parse `stringifiedValue` as a `bool`.
    function parseBool(string calldata stringifiedValue) external pure returns (bool);

    /// @dev Parse `stringifiedValue` as an `address`.
    function parseAddress(string calldata stringifiedValue) external pure returns (address);

    /// @dev Parse `stringifiedValue` as bytes.
    function parseBytes(string calldata stringifiedValue) external pure returns (bytes memory);

    /// @dev Parse `stringifiedValue` as a `bytes32`.
    function parseBytes32(string calldata stringifiedValue) external pure returns (bytes32);

    // [*] Code / wallet / ffi ================================================

    /// @dev Return creation bytecode for an artifact by name or
    ///      `File.sol:Name` id.
    function getCode(string calldata name) external view returns (bytes memory);

    /// @dev Derive an address from a private key.
    function addr(uint256 privateKey) external pure returns (address);

    /// @dev Sign `digest` with `privateKey`. Returns `(v, r, s)`.
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// @dev Execute an external command. Requires ripfuzz `--ffi`.
    function ffi(string[] calldata commandInput) external returns (bytes memory);

    // [*] Environment ========================================================

    /// @dev Read environment variable `key`. Reverts if the key is missing.
    function getEnv(string calldata key) external returns (string memory value);

    /// @dev Read environment variable `key`, or return `defaultValue` if missing.
    function getEnv(string calldata key, string calldata defaultValue) external returns (string memory value);

    // [*] Fork ===============================================================

    /// @dev RPC options for `fork`. Defaults match the two-argument
    ///      `fork(url, blockNumber)` form.
    struct ForkConfig {
        /// @dev Number of RPC retries after a failed request. Default: `3`.
        uint32 retries;
        /// @dev Backoff between retries in milliseconds. Default: `100`.
        uint64 backoffMs;
        /// @dev Per-request timeout in milliseconds. Default: `30000` (30s).
        uint64 timeoutMs;
        /// @dev Max RPC requests per second. Default: `0` (no rate limit).
        uint64 rateLimit;
    }

    /// @dev Create or select a remote chain fork at `url` and `blockNumber`.
    ///      Uses built-in defaults for retries, backoff, timeout, and rate limit.
    function fork(string calldata url, uint256 blockNumber) external;

    /// @dev Create or select a remote chain fork with custom RPC options.
    function fork(string calldata url, uint256 blockNumber, ForkConfig calldata config) external;
}
