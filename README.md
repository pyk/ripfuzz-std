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
git submodule add https://github.com/pyk/ripfuzz-std lib/ripfuzz-std
```

Then add this remapping so imports resolve as `ripfuzz/...`:

```bash
# remappings.txt
ripfuzz/=lib/ripfuzz-std/src/
```

Or in `foundry.toml`:

```toml
remappings = ["ripfuzz/=lib/ripfuzz-std/src/"]
```

## Example usage

Below is a minimal harness that uses ripfuzz cheatcodes to set up state and
check an invariant. Inherit from `Harness` to get an `rvm` instance pointed at
the ripfuzz VM address.

```solidity
// import ripfuzz-std
import {Harness} from "ripfuzz/Harness.sol";

contract Token {
    mapping(address => uint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = 1e27;
    }

    function transfer(address to, uint256 amount) public {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
    }
}

contract TokenHarness is Harness {
    Token token;
    address user;

    function setup() external {
        // fund an arbitrary user and deploy under that identity
        user = address(0xBEEF);
        rvm.deal(user, 100 ether);
        rvm.label(user, "user");

        rvm.prank(user);
        token = new Token();
    }

    function transfer(address to, uint256 amount) external {
        rvm.prank(user);
        token.transfer(to, amount);
    }

    function invariant_user_balance_never_increases_alone() external view {
        // toy invariant for illustration; real harnesses encode protocol rules
        assert(token.balanceOf(user) <= 1e27);
    }
}
```

Run the harness with ripfuzz:

```sh
ripfuzz run TokenHarness
```

## Available cheatcodes

| Category            | Cheatcodes                                                                                     |
| ------------------- | ---------------------------------------------------------------------------------------------- |
| Block               | `warp`, `roll`, `fee`, `coinbase`, `prevrandao`, `chainId`                                     |
| Account             | `deal`, `etch`, `setNonce`, `getNonce`, `store`, `load`                                        |
| Prank               | `prank`, `startPrank`, `stopPrank`                                                             |
| Label               | `label`, `getLabel`                                                                            |
| Conversion          | `toString`, `parseUint`, `parseInt`, `parseBool`, `parseAddress`, `parseBytes`, `parseBytes32` |
| Code / wallet / ffi | `getCode`, `addr`, `sign`, `ffi`                                                               |
| Environment         | `getEnv`                                                                                       |

The VM address is:

```text
0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
```

This is the same address as Foundry's HEVM
(`address(uint160(uint256(keccak256("hevm cheat code"))))`).
