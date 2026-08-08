// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";
import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
import {SafeERC20} from "ripfuzz/libraries/SafeERC20.sol";

/// @title ForkHarness
///
/// @dev Example of mainnet fork mode interacting with USDC. RPC URL is loaded
///      from `ETH_RPC_URL` via `rvm.getEnv` (for example from a `.env` file).
contract ForkHarness is Harness {
    using SafeERC20 for IERC20;

    // [*] Constants ==========================================================

    /// @dev Mainnet USDC.
    IERC20 internal constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    /// @dev Default Ethereum RPC when `ETH_RPC_URL` is unset.
    string internal constant DEFAULT_ETH_RPC_URL = "https://eth.meowrpc.com";

    /// @dev Fork block number.
    uint256 internal constant FORK_BLOCK = 25_708_159;

    /// @dev FiatToken `balances` mapping slot for USDC.
    uint256 internal constant USDC_BALANCE_SLOT = 9;

    /// @dev Initial USDC funded to Alice (6 decimals).
    uint256 internal constant INITIAL_ALICE_BALANCE = 1_000_000e6;

    // [*] Setup ==============================================================

    /// @dev Fork mainnet, register actors, and fund Alice with USDC.
    function setup() external {
        string memory rpcUrl = rvm.getEnv("ETH_RPC_URL", DEFAULT_ETH_RPC_URL);
        rvm.fork(rpcUrl, FORK_BLOCK);
        rvm.label(address(USDC), "USDC");

        addActor("Alice");
        addActor("Bob");

        address alice = getActor(0);
        _setUsdcBalance(alice, INITIAL_ALICE_BALANCE);

        eq(USDC.decimals(), 6, "usdc decimals");
        eq(USDC.balanceOf(alice), INITIAL_ALICE_BALANCE, "alice funded");
        ensure(USDC.totalSupply() > 0, "usdc total supply is live");
    }

    // [*] Handlers ===========================================================

    /// @dev Transfer USDC from the selected actor to the other actor.
    /// @param actorId Fuzzed actor index.
    /// @param amount Unbounded transfer amount.
    function transferUsdc(uint256 actorId, uint256 amount) external useActor(actorId) {
        uint256 bal = USDC.balanceOf(currentActor);
        if (bal == 0) return;

        amount = bound(amount, 1, bal);
        address to = getActor(actorId + 1);
        if (to == currentActor) return;

        USDC.safeTransfer(to, amount);
    }

    /// @dev Approve the other actor to spend a bounded USDC amount.
    /// @param actorId Fuzzed actor index.
    /// @param amount Unbounded allowance amount.
    function approveUsdc(uint256 actorId, uint256 amount) external useActor(actorId) {
        amount = bound(amount, 0, INITIAL_ALICE_BALANCE);
        address spender = getActor(actorId + 1);
        USDC.safeApprove(spender, amount);
    }

    // [*] Invariants =========================================================

    /// @dev Invariant: Alice and Bob conserve the USDC granted in `setup`.
    function invariant_ActorUsdcConserved() external {
        uint256 sum = USDC.balanceOf(getActor(0)) + USDC.balanceOf(getActor(1));
        eq(sum, INITIAL_ALICE_BALANCE, "actor usdc is conserved");
    }

    /// @dev Invariant: USDC still reports 6 decimals on the fork.
    function invariant_UsdcDecimals() external {
        eq(USDC.decimals(), 6, "usdc decimals");
    }

    // [*] Helpers ============================================================

    /// @dev Write USDC `balances[account]` via storage (FiatToken slot 9).
    /// @param account Token holder.
    /// @param amount New balance.
    function _setUsdcBalance(address account, uint256 amount) internal {
        bytes32 slot = keccak256(abi.encode(account, USDC_BALANCE_SLOT));
        rvm.store(address(USDC), slot, bytes32(amount));
    }
}
