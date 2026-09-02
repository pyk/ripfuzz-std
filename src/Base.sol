// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {RVM} from "./RVM.sol";

/// @title Base
///
/// @dev Base contract for scripts and harnesses. Provides the `rvm`
///      cheatcode interface at the ripfuzz VM address.
abstract contract Base {
    // [*] RVM ================================================================

    address internal constant RVM_ADDRESS = address(uint160(uint256(keccak256("ripfuzz cheatcode"))));

    RVM internal constant rvm = RVM(RVM_ADDRESS);
}
