// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC20} from "../interfaces/IERC20.sol";

/// @title SafeERC20
///
/// @dev Safe ERC20 helpers for ripfuzz harnesses. Uses low-level calls so
///      non-standard tokens (for example USDT, which does not return a bool
///      from `approve` / `transfer`) work in harnesses.
library SafeERC20 {
    // [*] Approve ============================================================

    /// @dev Safely approve `spender` to transfer tokens. Resets allowance to
    ///      zero first, then sets `amount` (USDT approve pattern). Avoids
    ///      Solidity return-data validation that reverts on void-returning
    ///      tokens.
    /// @param token The ERC20 token.
    /// @param spender The address allowed to spend tokens.
    /// @param amount The allowance amount.
    function safeApprove(IERC20 token, address spender, uint256 amount) internal {
        bytes4 selector = IERC20.approve.selector;

        (bool success0,) = address(token).call(abi.encodeWithSelector(selector, spender, 0));
        require(success0, "SafeERC20: approve(0) failed");

        (bool success1,) = address(token).call(abi.encodeWithSelector(selector, spender, amount));
        require(success1, "SafeERC20: approve(amount) failed");
    }

    // [*] Transfer ===========================================================

    /// @dev Safely transfer tokens from the caller to `to`. Accepts both
    ///      void-returning and bool-returning ERC20 implementations.
    /// @param token The ERC20 token.
    /// @param to The recipient address.
    /// @param amount The transfer amount.
    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        (bool success, bytes memory data) =
            address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: transfer failed");
    }
}
