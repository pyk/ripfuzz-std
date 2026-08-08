// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title CheatcodesHarness
///
/// @dev Example of common `rvm` cheatcodes.
contract CheatcodesHarness is Harness {
    address user;
    uint256 lastTimestamp;
    uint256 lastBalance;

    /// @dev Create a labeled user and snapshot baseline state.
    function setup() external {
        user = createAddress("user");
        lastTimestamp = block.timestamp;
        lastBalance = user.balance;
    }

    /// @dev Fund `user` with a bounded amount of ether.
    /// @param amount Unbounded fuzz input, clamped to `[1 wei, 10 ether]`.
    function dealUser(uint256 amount) external {
        amount = bound(amount, 1, 10 ether);
        rvm.deal(user, amount);
        lastBalance = amount;
    }

    /// @dev Warp time forward by a bounded delta.
    /// @param delta Unbounded fuzz input, clamped to `[1, 30 days]`.
    function warpForward(uint256 delta) external {
        delta = bound(delta, 1, 30 days);
        lastTimestamp = block.timestamp + delta;
        rvm.warp(lastTimestamp);
    }

    /// @dev Invariant: `user` balance matches the last `deal`.
    function invariant_BalanceMatchesDeal() external {
        eq(user.balance, lastBalance, "user balance matches last deal");
    }

    /// @dev Invariant: `block.timestamp` matches the last warp target.
    function invariant_TimestampMatchesWarp() external {
        eq(block.timestamp, lastTimestamp, "timestamp matches last warp");
    }
}
