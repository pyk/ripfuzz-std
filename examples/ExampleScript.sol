// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "ripfuzz/std.sol";

/// @title ExampleScript
///
/// @dev Example of a `ripfuzz exec` script with labeled accounts and logs.
///
///      Run with:
///
///      ripfuzz exec examples/ExampleScript.sol
///
///      The run prints the script logs to the terminal and saves the
///      execution trace under `.ripfuzz/traces`:
///
///      alice: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
///      done
contract ExampleScript is Script {
    /// @dev Deploy a counter owned by a labeled account, then increment it.
    function exec() external {
        address alice = rvm.addr(1);
        rvm.label(alice, "alice");
        rvm.deal(alice, 100 ether);

        log("alice: ", alice);
        log("done");
    }
}
