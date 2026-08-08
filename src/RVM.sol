// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title Ripfuzz Virtual Machine
///
/// @dev The ripfuzz VM is not fully Foundry-compatible. It implements only the
///      cheatcode subset supported by ripfuzz.
interface RVM {
    // [*] Block ==============================================================

    /// @dev Set `block.timestamp`.
    /// @param newTimestamp The new block timestamp.
    function warp(uint256 newTimestamp) external;

    /// @dev Set `block.number`.
    /// @param newNumber The new block number.
    function roll(uint256 newNumber) external;

    /// @dev Set `block.basefee`.
    /// @param newBasefee The new base fee.
    function fee(uint256 newBasefee) external;

    /// @dev Set `block.coinbase`.
    /// @param newCoinbase The new coinbase address.
    function coinbase(address newCoinbase) external;

    /// @dev Set `block.prevrandao`.
    /// @param newPrevrandao The new prevrandao value.
    function prevrandao(bytes32 newPrevrandao) external;

    /// @dev Set `block.chainid`.
    /// @param newChainId The new chain id.
    function chainId(uint256 newChainId) external;

    // [*] Account ============================================================

    /// @dev Set the ether balance of `account` to `value`.
    /// @param account The account to update.
    /// @param value The new ether balance.
    function deal(address account, uint256 value) external;

    /// @dev Set the bytecode of `account` to `code`.
    /// @param account The account to update.
    /// @param code The new runtime bytecode.
    function etch(address account, bytes calldata code) external;

    /// @dev Set the nonce of `account`. Reverts if `nonce` is lower than current.
    /// @param account The account to update.
    /// @param nonce The new nonce.
    function setNonce(address account, uint64 nonce) external;

    /// @dev Get the nonce of `account`.
    /// @param account The account to query.
    /// @return The account nonce.
    function getNonce(address account) external view returns (uint256);

    /// @dev Write `value` to storage `slot` of `account`.
    /// @param account The account whose storage is written.
    /// @param slot The storage slot.
    /// @param value The value to write.
    function store(address account, bytes32 slot, bytes32 value) external;

    /// @dev Read storage `slot` of `account`.
    /// @param account The account whose storage is read.
    /// @param slot The storage slot.
    /// @return The stored value.
    function load(address account, bytes32 slot) external view returns (bytes32);

    // [*] Prank ==============================================================

    /// @dev Set `msg.sender` for the next call.
    /// @param msgSender The address to use as `msg.sender`.
    function prank(address msgSender) external;

    /// @dev Set `msg.sender` and `tx.origin` for the next call.
    /// @param msgSender The address to use as `msg.sender`.
    /// @param txOrigin The address to use as `tx.origin`.
    function prank(address msgSender, address txOrigin) external;

    /// @dev Set `msg.sender` for all subsequent calls until `stopPrank`.
    /// @param msgSender The address to use as `msg.sender`.
    function startPrank(address msgSender) external;

    /// @dev Set `msg.sender` and `tx.origin` for all subsequent calls until
    ///      `stopPrank`.
    /// @param msgSender The address to use as `msg.sender`.
    /// @param txOrigin The address to use as `tx.origin`.
    function startPrank(address msgSender, address txOrigin) external;

    /// @dev Stop an active prank started with `startPrank`.
    function stopPrank() external;

    // [*] Label ==============================================================

    /// @dev Label `account` for clearer traces and logs.
    /// @param account The account to label.
    /// @param name The label to assign.
    function label(address account, string calldata name) external;

    /// @dev Get the label previously set for `account`.
    /// @param account The account to query.
    /// @return The account label.
    function getLabel(address account) external view returns (string memory);

    // [*] Conversion =========================================================

    /// @dev Convert `value` to its string representation.
    /// @param value The address to convert.
    /// @return The string representation.
    function toString(address value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    /// @param value The bool to convert.
    /// @return The string representation.
    function toString(bool value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    /// @param value The uint256 to convert.
    /// @return The string representation.
    function toString(uint256 value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    /// @param value The int256 to convert.
    /// @return The string representation.
    function toString(int256 value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    /// @param value The bytes32 to convert.
    /// @return The string representation.
    function toString(bytes32 value) external pure returns (string memory);

    /// @dev Convert `value` to its string representation.
    /// @param value The bytes to convert.
    /// @return The string representation.
    function toString(bytes calldata value) external pure returns (string memory);

    /// @dev Parse `stringifiedValue` as a `uint256`.
    /// @param stringifiedValue The string to parse.
    /// @return The parsed uint256.
    function parseUint(string calldata stringifiedValue) external pure returns (uint256);

    /// @dev Parse `stringifiedValue` as an `int256`.
    /// @param stringifiedValue The string to parse.
    /// @return The parsed int256.
    function parseInt(string calldata stringifiedValue) external pure returns (int256);

    /// @dev Parse `stringifiedValue` as a `bool`.
    /// @param stringifiedValue The string to parse.
    /// @return The parsed bool.
    function parseBool(string calldata stringifiedValue) external pure returns (bool);

    /// @dev Parse `stringifiedValue` as an `address`.
    /// @param stringifiedValue The string to parse.
    /// @return The parsed address.
    function parseAddress(string calldata stringifiedValue) external pure returns (address);

    /// @dev Parse `stringifiedValue` as bytes.
    /// @param stringifiedValue The string to parse.
    /// @return The parsed bytes.
    function parseBytes(string calldata stringifiedValue) external pure returns (bytes memory);

    /// @dev Parse `stringifiedValue` as a `bytes32`.
    /// @param stringifiedValue The string to parse.
    /// @return The parsed bytes32.
    function parseBytes32(string calldata stringifiedValue) external pure returns (bytes32);

    // [*] Code / wallet / ffi ================================================

    /// @dev Return creation bytecode for an artifact by name or
    ///      `File.sol:Name` id.
    /// @param name The artifact name or `File.sol:Name` id.
    /// @return The creation bytecode.
    function getCode(string calldata name) external view returns (bytes memory);

    /// @dev Derive an address from a private key.
    /// @param privateKey The private key.
    /// @return The derived address.
    function addr(uint256 privateKey) external pure returns (address);

    /// @dev Sign `digest` with `privateKey`.
    /// @param privateKey The private key used to sign.
    /// @param digest The 32-byte digest to sign.
    /// @return v Recovery id.
    /// @return r First 32 bytes of the signature.
    /// @return s Second 32 bytes of the signature.
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// @dev Execute an external command. Requires ripfuzz `--ffi`.
    /// @param commandInput The command and arguments to execute.
    /// @return The command stdout as bytes.
    function ffi(string[] calldata commandInput) external returns (bytes memory);

    // [*] Environment ========================================================

    /// @dev Read environment variable `key`. Reverts if the key is missing.
    /// @param key The environment variable name.
    /// @return value The environment variable value.
    function getEnv(string calldata key) external returns (string memory value);

    /// @dev Read environment variable `key`, or return `defaultValue` if missing.
    /// @param key The environment variable name.
    /// @param defaultValue The value to return when `key` is missing.
    /// @return value The environment variable value, or `defaultValue`.
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
    /// @param url The RPC URL.
    /// @param blockNumber The block number to fork at.
    function fork(string calldata url, uint256 blockNumber) external;

    /// @dev Create or select a remote chain fork with custom RPC options.
    /// @param url The RPC URL.
    /// @param blockNumber The block number to fork at.
    /// @param config Custom RPC retry, backoff, timeout, and rate-limit options.
    function fork(string calldata url, uint256 blockNumber, ForkConfig calldata config) external;
}
