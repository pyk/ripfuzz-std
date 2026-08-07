// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {RVM} from "./RVM.sol";

/// @title Ripfuzz Harness
/// @dev Base contract for ripfuzz harnesses. Inherit from this contract to
///      access the ripfuzz VM cheatcodes via `rvm`.
abstract contract Harness {
    address internal constant RVM_ADDRESS = address(uint160(uint256(keccak256("ripfuzz cheatcode"))));

    RVM internal constant rvm = RVM(RVM_ADDRESS);
}
