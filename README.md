# Ripfuzz Standard Library

Ripfuzz standard library cheatcodes and harness helpers for writing
coverage-guided fuzz harnesses. These interfaces are intended for
[ripfuzz][ripfuzz]. They cover the Foundry-style cheatcode subset that ripfuzz
currently implements.

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
the ripfuzz VM address.

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
        rvm.prank(user);
        counter.add(x);
    }

    function invariant_CountStaysSmall() external view {
        assert(counter.count() < 1000);
    }
}
```

Run the harness with ripfuzz:

```sh
ripfuzz run CounterHarness
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
