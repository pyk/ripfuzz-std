// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @notice Ripfuzz Virtual Machine
///
/// @dev The ripfuzz VM is not fully Foundry-compatible. It implements only the
/// cheatcode subset supported by ripfuzz. The address matches Foundry's HEVM
/// address so existing `vm` references keep working.
interface RVM {
    // [*] Block ==============================================================

    /// Set `block.timestamp`.
    function warp(uint256 newTimestamp) external;

    /// Set `block.number`.
    function roll(uint256 newNumber) external;

    /// Set `block.basefee`.
    function fee(uint256 newBasefee) external;

    /// Set `block.coinbase`.
    function coinbase(address newCoinbase) external;

    /// Set `block.prevrandao`.
    function prevrandao(bytes32 newPrevrandao) external;

    /// Set `block.chainid`.
    function chainId(uint256 newChainId) external;

    // [*] Account ============================================================

    /// Set the ether balance of `account` to `value`.
    function deal(address account, uint256 value) external;

    /// Set the bytecode of `account` to `code`.
    function etch(address account, bytes calldata code) external;

    /// Set the nonce of `account`. Reverts if `nonce` is lower than current.
    function setNonce(address account, uint64 nonce) external;

    /// Get the nonce of `account`.
    function getNonce(address account) external view returns (uint256);

    /// Write `value` to storage `slot` of `account`.
    function store(address account, bytes32 slot, bytes32 value) external;

    /// Read storage `slot` of `account`.
    function load(address account, bytes32 slot) external view returns (bytes32);

    // [*] Prank ==============================================================

    /// Set `msg.sender` for the next call.
    function prank(address msgSender) external;

    /// Set `msg.sender` and `tx.origin` for the next call.
    function prank(address msgSender, address txOrigin) external;

    /// Set `msg.sender` for all subsequent calls until `stopPrank`.
    function startPrank(address msgSender) external;

    /// Set `msg.sender` and `tx.origin` for all subsequent calls until `stopPrank`.
    function startPrank(address msgSender, address txOrigin) external;

    /// Stop an active prank started with `startPrank`.
    function stopPrank() external;

    // [*] Label ==============================================================

    /// Label `account` for clearer traces and logs.
    function label(address account, string calldata name) external;

    /// Get the label previously set for `account`.
    function getLabel(address account) external view returns (string memory);

    // [*] Conversion =========================================================

    function toString(address value) external pure returns (string memory);
    function toString(bool value) external pure returns (string memory);
    function toString(uint256 value) external pure returns (string memory);
    function toString(int256 value) external pure returns (string memory);
    function toString(bytes32 value) external pure returns (string memory);
    function toString(bytes calldata value) external pure returns (string memory);

    function parseUint(string calldata stringifiedValue) external pure returns (uint256);
    function parseInt(string calldata stringifiedValue) external pure returns (int256);
    function parseBool(string calldata stringifiedValue) external pure returns (bool);
    function parseAddress(string calldata stringifiedValue) external pure returns (address);
    function parseBytes(string calldata stringifiedValue) external pure returns (bytes memory);
    function parseBytes32(string calldata stringifiedValue) external pure returns (bytes32);

    // [*] Code / wallet / ffi ================================================

    /// Return creation bytecode for an artifact by name or `File.sol:Name` id.
    function getCode(string calldata name) external view returns (bytes memory);

    /// Derive an address from a private key.
    function addr(uint256 privateKey) external pure returns (address);

    /// Sign `digest` with `privateKey`. Returns `(v, r, s)`.
    function sign(uint256 privateKey, bytes32 digest) external pure returns (uint8 v, bytes32 r, bytes32 s);

    /// Execute an external command. Requires ripfuzz `--ffi`.
    function ffi(string[] calldata commandInput) external returns (bytes memory);

    // [*] Environment ========================================================

    /// Read environment variable `key`. Reverts if the key is missing.
    function getEnv(string calldata key) external returns (string memory value);

    /// Read environment variable `key`, or return `defaultValue` if missing.
    function getEnv(string calldata key, string calldata defaultValue) external returns (string memory value);
}
