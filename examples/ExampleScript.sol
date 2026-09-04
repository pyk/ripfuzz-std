// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script} from "ripfuzz/std.sol";

/// @title ExampleScript
///
/// @dev Example of a `ripfuzz exec` script with a labeled account and logs.
///
///      Run with:
///
///      ripfuzz exec examples/ExampleScript.sol
///
///      The run prints the script logs to the terminal and saves the
///      execution trace under `.ripfuzz/traces`:
///
///      alice: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
///      done
contract ExampleScript is Script {
    /// @dev Fund a labeled account, then log its address.
    function exec() external {
        address alice = rvm.addr(1);
        label(alice, "alice");
        deal(alice, 100 ether);

        log("alice: ", alice);
        log("done");
    }
}
