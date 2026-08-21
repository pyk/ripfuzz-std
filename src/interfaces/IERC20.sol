// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/// @title IERC20
///
/// @dev Minimal ERC20 interface with metadata and EIP-2612 permit support for
///      harnesses. Bundles core, metadata, and permit methods so handlers do
///      not need separate OpenZeppelin IERC20Metadata / IERC20Permit imports.
interface IERC20 {
    // [*] ERC20 ==============================================================

    /// @dev Return the remaining allowance of `spender` over `owner` tokens.
    /// @param owner The token owner.
    /// @param spender The approved spender.
    /// @return The remaining allowance.
    function allowance(address owner, address spender) external view returns (uint256);

    /// @dev Set `amount` as the allowance of `spender` over the caller's
    ///      tokens.
    /// @param spender The address allowed to spend tokens.
    /// @param amount The allowance amount.
    /// @return True if the operation succeeded.
    function approve(address spender, uint256 amount) external returns (bool);

    /// @dev Return the token balance of `account`.
    /// @param account The account to query.
    /// @return The token balance.
    function balanceOf(address account) external view returns (uint256);

    /// @dev Return the total token supply.
    /// @return The total supply.
    function totalSupply() external view returns (uint256);

    /// @dev Transfer `amount` tokens from the caller to `to`.
    /// @param to The recipient address.
    /// @param amount The transfer amount.
    /// @return True if the operation succeeded.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @dev Transfer `amount` tokens from `from` to `to` using the caller's
    ///      allowance.
    /// @param from The token owner.
    /// @param to The recipient address.
    /// @param amount The transfer amount.
    /// @return True if the operation succeeded.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    // [*] Metadata ===========================================================

    /// @dev Return the number of decimals used to represent token amounts.
    /// @return The token decimals.
    function decimals() external view returns (uint8);

    // [*] Permit =============================================================

    /// @dev Return the EIP-712 domain separator for the token.
    /// @return The domain separator.
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /// @dev Return the current permit nonce for `owner`.
    /// @param owner The token owner.
    /// @return The current nonce.
    function nonces(address owner) external view returns (uint256);

    /// @dev Set `value` as the allowance of `spender` over `owner` tokens
    ///      given a signed approval.
    /// @param owner The token owner.
    /// @param spender The address allowed to spend tokens.
    /// @param value The allowance amount.
    /// @param deadline The expiry timestamp after which the signature is invalid.
    /// @param v Recovery byte of the signature.
    /// @param r First 32 bytes of the signature.
    /// @param s Second 32 bytes of the signature.
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
}
