// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";
import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
import {SafeERC20} from "ripfuzz/libraries/SafeERC20.sol";

/// @title MultiForkHarness
///
/// @dev Example of switching between Ethereum and Base forks while interacting
///      with native USDC on each chain. RPC URLs are loaded from `ETH_RPC_URL`
///      and `BASE_RPC_URL` via `rvm.getEnv` (for example from a `.env` file).
contract MultiForkHarness is Harness {
    using SafeERC20 for IERC20;

    // [*] Ethereum ===========================================================

    /// @dev Ethereum mainnet USDC.
    IERC20 internal constant ETH_USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    /// @dev Default Ethereum RPC when `ETH_RPC_URL` is unset.
    string internal constant DEFAULT_ETH_RPC_URL = "https://eth.meowrpc.com";

    /// @dev Ethereum fork block number.
    uint256 internal constant ETH_FORK_BLOCK = 25_708_159;

    /// @dev Ethereum RPC loaded in `setup`.
    string internal ethRpcUrl;

    // [*] Base ===============================================================

    /// @dev Base USDC.
    IERC20 internal constant BASE_USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);

    /// @dev Default Base RPC when `BASE_RPC_URL` is unset.
    string internal constant DEFAULT_BASE_RPC_URL = "https://base.meowrpc.com";

    /// @dev Base fork block number.
    uint256 internal constant BASE_FORK_BLOCK = 49_688_843;

    /// @dev Base RPC loaded in `setup`.
    string internal baseRpcUrl;

    // [*] Shared =============================================================

    /// @dev FiatToken `balances` mapping slot for USDC on both chains.
    uint256 internal constant USDC_BALANCE_SLOT = 9;

    /// @dev Initial USDC funded to Alice on each chain (6 decimals).
    uint256 internal constant INITIAL_ALICE_BALANCE = 1_000_000e6;

    // [*] Modifiers ==========================================================

    /// @dev Select the Ethereum fork for the duration of the call.
    modifier onEthereum() {
        rvm.fork(ethRpcUrl, ETH_FORK_BLOCK);
        _;
    }

    /// @dev Select the Base fork for the duration of the call.
    modifier onBase() {
        rvm.fork(baseRpcUrl, BASE_FORK_BLOCK);
        _;
    }

    // [*] Setup ==============================================================

    /// @dev Load RPC URLs, create both forks, register actors, and fund Alice.
    function setup() external {
        ethRpcUrl = rvm.getEnv("ETH_RPC_URL", DEFAULT_ETH_RPC_URL);
        baseRpcUrl = rvm.getEnv("BASE_RPC_URL", DEFAULT_BASE_RPC_URL);

        addActor("Alice");
        addActor("Bob");
        address alice = getActor(0);

        _fundEthereum(alice);
        _fundBase(alice);
    }

    /// @dev Fund Alice on Ethereum USDC.
    /// @param alice Actor to fund.
    function _fundEthereum(address alice) internal onEthereum {
        rvm.label(address(ETH_USDC), "ETH-USDC");
        _setUsdcBalance(address(ETH_USDC), alice, INITIAL_ALICE_BALANCE);
        eq(ETH_USDC.decimals(), 6, "eth usdc decimals");
        eq(ETH_USDC.balanceOf(alice), INITIAL_ALICE_BALANCE, "eth alice funded");
    }

    /// @dev Fund Alice on Base USDC.
    /// @param alice Actor to fund.
    function _fundBase(address alice) internal onBase {
        rvm.label(address(BASE_USDC), "BASE-USDC");
        _setUsdcBalance(address(BASE_USDC), alice, INITIAL_ALICE_BALANCE);
        eq(BASE_USDC.decimals(), 6, "base usdc decimals");
        eq(BASE_USDC.balanceOf(alice), INITIAL_ALICE_BALANCE, "base alice funded");
    }

    // [*] Ethereum handlers ==================================================

    /// @dev Transfer Ethereum USDC between actors.
    /// @param actorId Fuzzed actor index.
    /// @param amount Unbounded transfer amount.
    function transferEthUsdc(uint256 actorId, uint256 amount) external onEthereum useActor(actorId) {
        _transferUsdc(ETH_USDC, actorId, amount);
    }

    /// @dev Approve Ethereum USDC spending between actors.
    /// @param actorId Fuzzed actor index.
    /// @param amount Unbounded allowance amount.
    function approveEthUsdc(uint256 actorId, uint256 amount) external onEthereum useActor(actorId) {
        _approveUsdc(ETH_USDC, actorId, amount);
    }

    // [*] Base handlers ======================================================

    /// @dev Transfer Base USDC between actors.
    /// @param actorId Fuzzed actor index.
    /// @param amount Unbounded transfer amount.
    function transferBaseUsdc(uint256 actorId, uint256 amount) external onBase useActor(actorId) {
        _transferUsdc(BASE_USDC, actorId, amount);
    }

    /// @dev Approve Base USDC spending between actors.
    /// @param actorId Fuzzed actor index.
    /// @param amount Unbounded allowance amount.
    function approveBaseUsdc(uint256 actorId, uint256 amount) external onBase useActor(actorId) {
        _approveUsdc(BASE_USDC, actorId, amount);
    }

    // [*] Invariants =========================================================

    /// @dev Invariant: Ethereum actor USDC balances stay conserved.
    function invariant_EthActorUsdcConserved() external onEthereum {
        uint256 sum = ETH_USDC.balanceOf(getActor(0)) + ETH_USDC.balanceOf(getActor(1));
        eq(sum, INITIAL_ALICE_BALANCE, "eth actor usdc is conserved");
    }

    /// @dev Invariant: Base actor USDC balances stay conserved.
    function invariant_BaseActorUsdcConserved() external onBase {
        uint256 sum = BASE_USDC.balanceOf(getActor(0)) + BASE_USDC.balanceOf(getActor(1));
        eq(sum, INITIAL_ALICE_BALANCE, "base actor usdc is conserved");
    }

    /// @dev Invariant: both USDCs report 6 decimals.
    function invariant_UsdcDecimals() external {
        _checkEthDecimals();
        _checkBaseDecimals();
    }

    /// @dev Check Ethereum USDC decimals.
    function _checkEthDecimals() internal onEthereum {
        eq(ETH_USDC.decimals(), 6, "eth usdc decimals");
    }

    /// @dev Check Base USDC decimals.
    function _checkBaseDecimals() internal onBase {
        eq(BASE_USDC.decimals(), 6, "base usdc decimals");
    }

    // [*] Helpers ============================================================

    /// @dev Transfer `amount` of `token` from `currentActor` to another actor.
    /// @param token USDC token on the active fork.
    /// @param actorId Active actor index used to pick the recipient.
    /// @param amount Unbounded transfer amount.
    function _transferUsdc(IERC20 token, uint256 actorId, uint256 amount) internal {
        uint256 bal = token.balanceOf(currentActor);
        if (bal == 0) return;

        amount = bound(amount, 1, bal);
        address to = getActor(actorId + 1);
        if (to == currentActor) return;

        token.safeTransfer(to, amount);
    }

    /// @dev Approve another actor for a bounded `token` allowance.
    /// @param token USDC token on the active fork.
    /// @param actorId Active actor index used to pick the spender.
    /// @param amount Unbounded allowance amount.
    function _approveUsdc(IERC20 token, uint256 actorId, uint256 amount) internal {
        amount = bound(amount, 0, INITIAL_ALICE_BALANCE);
        address spender = getActor(actorId + 1);
        token.safeApprove(spender, amount);
    }

    /// @dev Write USDC `balances[account]` via storage (FiatToken slot 9).
    /// @param token USDC token address on the active fork.
    /// @param account Token holder.
    /// @param amount New balance.
    function _setUsdcBalance(address token, address account, uint256 amount) internal {
        bytes32 slot = keccak256(abi.encode(account, USDC_BALANCE_SLOT));
        rvm.store(token, slot, bytes32(amount));
    }
}
