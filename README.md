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
        user = createAddress("user");
        rvm.deal(user, 100 ether);

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

## License

MIT
