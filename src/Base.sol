// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Deal} from "./libraries/Deal.sol";
import {RVM} from "./RVM.sol";

/// @title Base
///
/// @dev Base contract for scripts and harnesses. Provides the `rvm`
///      cheatcode interface at the ripfuzz VM address.
abstract contract Base {
    // [*] RVM ================================================================

    address internal constant RVM_ADDRESS = address(uint160(uint256(keccak256("ripfuzz cheatcode"))));

    RVM internal constant rvm = RVM(RVM_ADDRESS);

    // [*] Deal ===============================================================

    /// @dev Cached `balanceOf` mapping slot for a dealt token.
    struct DealSlot {
        /// @dev The mapping slot index.
        uint256 slot;
        /// @dev The mapping key layout.
        Deal.Layout layout;
        /// @dev Whether the slot has been probed.
        bool found;
    }

    /// @dev Balance slot cache keyed by token address.
    mapping(address => DealSlot) internal _dealSlots;

    /// @dev Set the ether balance of `account` to `value`.
    /// @param account The account to update.
    /// @param value The new ether balance.
    function deal(address account, uint256 value) internal {
        rvm.deal(account, value);
    }

    /// @dev Set the ERC20 balance of `to` on `token` to `value`. The
    ///      `balanceOf` mapping slot is probed once per token and cached, so
    ///      repeated deals on the same token skip the probe. Reverts when the
    ///      balance slot cannot be found.
    /// @param token The ERC20 token.
    /// @param to The recipient account.
    /// @param value The new token balance.
    function deal(address token, address to, uint256 value) internal {
        DealSlot storage cached = _dealSlots[token];
        if (!cached.found) {
            (cached.slot, cached.layout) = Deal.findBalanceSlot(token);
            cached.found = true;
        }
        Deal.deal(token, to, value, cached.slot, cached.layout);
    }
}
