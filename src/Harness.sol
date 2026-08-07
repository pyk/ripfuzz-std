// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {RVM} from "./RVM.sol";

/// @notice Base contract for ripfuzz harnesses.
///
/// Inherit from this contract to access the ripfuzz VM cheatcodes via `rvm`.
abstract contract Harness {
    // RVM cheat code address: 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    // Same address as Foundry HEVM (`keccak256("hevm cheat code")`).
    address internal constant RVM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    RVM internal constant rvm = RVM(RVM_ADDRESS);
}
