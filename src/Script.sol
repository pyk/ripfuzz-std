// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Base} from "./Base.sol";
import {Logger} from "./Logger.sol";

/// @title Ripfuzz Script
///
/// @dev Base contract for `ripfuzz exec` scripts. Run once by defining
///      `setup` (optional) and `exec`. Logs printed via `log` render in the
///      terminal output of the run.
abstract contract Script is Logger, Base {}
