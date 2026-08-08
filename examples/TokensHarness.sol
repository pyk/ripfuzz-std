// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";
import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
import {SafeERC20} from "ripfuzz/libraries/SafeERC20.sol";

/// @title MockERC20
///
/// @dev Minimal ERC20 used by `TokensHarness`.
contract MockERC20 {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /// @dev Mint `amount` tokens to `to`.
    /// @param to Token recipient.
    /// @param amount Mint amount.
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    /// @dev Approve `spender` for `amount`.
    /// @param spender Approved spender.
    /// @param amount Allowance amount.
    /// @return True on success.
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    /// @dev Transfer `amount` tokens to `to`.
    /// @param to Token recipient.
    /// @param amount Transfer amount.
    /// @return True on success.
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

/// @title TokensHarness
///
/// @dev Example of `SafeERC20` approve and transfer helpers.
contract TokensHarness is Harness {
    using SafeERC20 for IERC20;

    MockERC20 internal mock;
    IERC20 internal token;
    address internal recipient;

    /// @dev Deploy a mock token and fund the harness.
    function setup() external {
        mock = new MockERC20();
        token = IERC20(address(mock));
        recipient = createAddress("recipient");

        mock.mint(address(this), 1_000_000 ether);
    }

    /// @dev Safely transfer a bounded amount to `recipient`.
    /// @param amount Unbounded fuzz input, clamped to available balance.
    function transferToRecipient(uint256 amount) external {
        uint256 balance = mock.balanceOf(address(this));
        if (balance == 0) return;
        amount = bound(amount, 1, balance);
        token.safeTransfer(recipient, amount);
    }

    /// @dev Safely approve a bounded allowance for `recipient`.
    /// @param amount Unbounded fuzz input.
    function approveRecipient(uint256 amount) external {
        amount = bound(amount, 0, 1_000_000 ether);
        token.safeApprove(recipient, amount);
    }

    /// @dev Invariant: token supply is conserved between harness and recipient.
    function invariant_SupplyConserved() external {
        uint256 total = mock.balanceOf(address(this)) + mock.balanceOf(recipient);
        eq(total, 1_000_000 ether, "token supply is conserved");
    }
}
