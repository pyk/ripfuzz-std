// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
import {Script} from "ripfuzz/std.sol";

/// @title ExampleDeal
///
/// @dev Example of dealing ether and ERC20 balances on a pinned mainnet fork
///      with the `deal` helpers. Deals WETH (Solidity mapping layout) and CRV
///      (Vyper mapping layout) to a labeled account and asserts both balances.
///
///      Run with:
///
///      ripfuzz exec examples/ExampleDeal.sol
///
///      The run prints the script logs to the terminal and saves the
///      execution trace under `.ripfuzz/traces`:
///
///      alice: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
///      alice WETH: 100000000000000000000
///      alice CRV: 100000000000000000000000
///      done
contract ExampleDeal is Script {
    // [*] Fork ===============================================================

    /// @dev RPC URL of the forked chain.
    string internal constant RPC_URL = "https://1.rpc.thirdweb.com";

    /// @dev Block number the fork is pinned to. If the run fails because the
    ///      block is too old, get the latest block with `cast block-number
    ///      --rpc-url https://1.rpc.thirdweb.com` and update the pin.
    uint256 internal constant BLOCK_NUMBER = 25_903_397;

    // [*] Tokens =============================================================

    /// @dev Wrapped Ether with the Solidity balance mapping layout at slot 3.
    IERC20 internal constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    /// @dev Curve DAO token with the Vyper balance mapping layout at slot 3.
    IERC20 internal constant CRV = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);

    // [*] Exec ===============================================================

    /// @dev Fund `alice` with ether, WETH, and CRV, then assert the balances.
    function exec() external {
        fork(RPC_URL, BLOCK_NUMBER);

        address alice = rvm.addr(1);
        label(alice, "alice");

        deal(alice, 100 ether);
        deal(address(WETH), alice, 100 ether);
        deal(address(CRV), alice, 100_000e18);

        require(alice.balance == 100 ether, "ExampleDeal: ether balance");
        require(WETH.balanceOf(alice) == 100 ether, "ExampleDeal: WETH balance");
        require(CRV.balanceOf(alice) == 100_000e18, "ExampleDeal: CRV balance");

        log("alice: ", alice);
        log("alice WETH: ", WETH.balanceOf(alice));
        log("alice CRV: ", CRV.balanceOf(alice));
        log("done");
    }
}
