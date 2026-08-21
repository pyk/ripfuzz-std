// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC20} from "./IERC20.sol";

/// @title IWETH
///
/// @dev Wrapped native token interface for harnesses. Extends `IERC20` with
///      `deposit` and `withdraw` so handlers can wrap and unwrap ETH without a
///      separate WETH ABI.
interface IWETH is IERC20 {
    // [*] WETH ===============================================================

    /// @dev Deposit ETH and mint WETH to the caller.
    function deposit() external payable;

    /// @dev Burn `amount` WETH and send ETH to the caller.
    /// @param amount The WETH amount to unwrap.
    function withdraw(uint256 amount) external;
}
