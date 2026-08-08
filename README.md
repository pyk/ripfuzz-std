# Ripfuzz Standard Library

Standard library for writing [ripfuzz][ripfuzz] harnesses.

Please refer to [the list of currently available cheatcodes][list]. More
cheatcodes will be added as ripfuzz grows support.

[ripfuzz]: <https://github.com/pyk/ripfuzz>
[list]: <src/RVM.sol>

## Installation

To install using Foundry:

```bash
forge install pyk/ripfuzz-std
```

Alternatively, you can directly add it as a submodule:

```bash
git submodule add https://github.com/pyk/ripfuzz-std
```

## Example usage

Below is a minimal harness that uses ripfuzz cheatcodes to set up state and
check an invariant. Inherit from `Harness` to get an `rvm` instance pointed at
the ripfuzz VM address, plus `log`, assertions, and `bound`.

```solidity
// import ripfuzz-std
import {Harness} from "ripfuzz/Harness.sol";

contract Counter {
    uint256 public count;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function increment() external {
        require(msg.sender == owner, "not owner");
        count += 1;
    }

    function add(uint256 x) external {
        require(msg.sender == owner, "not owner");
        count += x;
    }
}

contract CounterHarness is Harness {
    Counter counter;
    address user;

    function setup() external {
        user = address(0xBEEF);
        rvm.deal(user, 100 ether);
        rvm.label(user, "user");

        // Deploy as `user` so that user owns the counter.
        rvm.prank(user);
        counter = new Counter();
    }

    function increment() external {
        rvm.prank(user);
        counter.increment();
    }

    function add(uint256 x) external {
        x = bound(x, 1, 100);
        rvm.prank(user);
        counter.add(x);
    }

    function invariant_OwnerIsUser() external {
        eq(counter.owner(), user, "owner is user");
    }

    function invariant_CountStaysBounded() external {
        ensure(counter.count() < 1_000_000, "count stayed below 1_000_000");
    }
}
```

Run the harness with ripfuzz:

```sh
ripfuzz run CounterHarness
```

## Modules

| Module       | Import                            | Purpose                                            |
| ------------ | --------------------------------- | -------------------------------------------------- |
| `Harness`    | `ripfuzz/Harness.sol`             | Base contract: `rvm`, logging, assertions, `bound` |
| `RVM`        | `ripfuzz/RVM.sol`                 | Cheatcode interface                                |
| `Logger`     | `ripfuzz/Logger.sol`              | `log(...)` helpers via `Log` events                |
| `Assertions` | `ripfuzz/Assertions.sol`          | `ensure`, `eq`, `neq`, `unreachable`               |
| `Bound`      | `ripfuzz/libraries/Bound.sol`     | Clamp fuzz inputs into a range                     |
| `SafeERC20`  | `ripfuzz/libraries/SafeERC20.sol` | Safe approve / transfer for non-standard tokens    |
| `IERC20`     | `ripfuzz/interfaces/IERC20.sol`   | Minimal ERC20 + metadata + permit interface        |

`Harness` inherits `Assertions` (and therefore `Logger`) and exposes `bound`,
so most harnesses only need:

```solidity
import {Harness} from "ripfuzz/Harness.sol";
```

For token helpers:

```solidity
import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
import {SafeERC20} from "ripfuzz/libraries/SafeERC20.sol";

using SafeERC20 for IERC20;
```

## Available cheatcodes

| Category    | Cheatcodes                                                                                     |
| ----------- | ---------------------------------------------------------------------------------------------- |
| Block       | `warp`, `roll`, `fee`, `coinbase`, `prevrandao`, `chainId`                                     |
| Account     | `deal`, `etch`, `setNonce`, `getNonce`, `store`, `load`                                        |
| Prank       | `prank`, `startPrank`, `stopPrank`                                                             |
| Label       | `label`, `getLabel`                                                                            |
| Conversion  | `toString`, `parseUint`, `parseInt`, `parseBool`, `parseAddress`, `parseBytes`, `parseBytes32` |
| Bytecode    | `getCode`                                                                                      |
| Wallet      | `addr`, `sign`                                                                                 |
| FFI         | `ffi`                                                                                          |
| Environment | `getEnv`                                                                                       |
| Fork        | `fork`                                                                                         |

The RVM address is:

```text
0x628dC59F11F72B611132eC40437F125ba1312F08
```

Calculated as:

```text
address(uint160(uint256(keccak256("ripfuzz cheatcode"))))
```
