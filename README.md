# Ripfuzz Standard Library

Standard library for writing [ripfuzz][ripfuzz] harnesses.

[ripfuzz]: <https://github.com/pyk/ripfuzz>

## Installation

Clone the repository into your project and add a remapping:

```bash
git clone https://github.com/pyk/ripfuzz-std lib/ripfuzz-std
```

```text
# remappings.txt
ripfuzz/=lib/ripfuzz-std/src/
```

> [!NOTE]
>
> A `ripfuzz fetch` command to install pinned releases is planned:
>
> ```bash
> ripfuzz fetch https://github.com/pyk/ripfuzz-std/archive/v2.0.0.tar.gz
> ```

## Usage

ripfuzz has three use cases:

| Command        | Use case               |
| :------------- | :--------------------- |
| `ripfuzz test` | Find broken invariants |
| `ripfuzz max`  | Find the maximum value |
| `ripfuzz exec` | Execute a script once  |

## Invariant testing

Invariant testing checks that properties of your protocol hold after every
sequence of state-changing calls. Ripfuzz deploys your test contract, runs
`setup()` once, generates sequences of handler calls, and runs every
`invariant_*` function after each call. A broken invariant is reported with the
shortest sequence that reproduces it.

End-to-end example:
[`examples/ExampleInvariantTest.sol`](examples/ExampleInvariantTest.sol), run
by `make test`.

### 1. Write the invariant test

A invariant test contract inherits `InvariantTest` and has three kinds of
functions:

- **Setup**: `setup()` runs once before fuzzing. Deploy the target protocol and
  prepare state.
- **Handlers**: external or public functions the fuzzer calls with random
  inputs to mutate state.
- **Invariant functions**: functions prefixed with `invariant_` that take no
  arguments. Ripfuzz runs them after every handler call.

Declare each invariant as a handle with `createInvariant`, then assert with the
check family: `ensure`, `eq`, `neq`, `gt`, `gte`, `lt`, `lte`. A failed check
reports the invariant by id through `rvm.bail`.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {InvariantTest} from "ripfuzz/std.sol";

contract Counter {
    // [*] State ==============================================================

    uint256 public count;
    address public owner;

    // [*] Constructor ========================================================

    constructor() {
        owner = msg.sender;
    }

    // [*] Handlers ===========================================================

    function add(uint256 x) external {
        count += x;
    }
}

contract ExampleInvariantTest is InvariantTest {
    // [*] Invariants =========================================================

    Invariant internal invOwner = createInvariant("INV-01", "owner never changes");
    Invariant internal invSmall = createInvariant("INV-02", "count must stay small");

    // [*] State ==============================================================

    Counter internal counter;

    // [*] Setup ==============================================================

    function setup() external {
        addActor("user");
        rvm.prank(getActor(0));
        counter = new Counter();
    }

    // [*] Handlers ===========================================================

    function add(uint256 actorId, uint256 x) external useActor(actorId) {
        x = bound(x, 1, 10);
        counter.add(x);
    }

    // [*] Invariant functions ================================================

    function invariant_OwnerNeverChanges() external {
        eq(counter.owner(), getActor(0), invOwner);
    }

    function invariant_CountStaysSmall() external {
        lt(counter.count(), 100, invSmall);
    }
}
```

### 2. Run the invariant test

```sh
ripfuzz test examples/ExampleInvariantTest.sol
```

Ripfuzz compiles the harness, deploys it, runs `setup()`, then fuzzes. The
example reports one broken invariant: fourteen `add` calls push `count` to
`100`:

```text
fuzzing started: 2 threads, 2000 runs, max 20 calls, 2 invariants, 120s timeout
found broken invariant INV-02
fuzzing finished: 1 broken invariant, 2000 runs, 0s
shrinking started: 1 broken invariant, 2 threads, 10000 runs
broken invariant INV-02 minimized from 14 calls to 14
shrinking finished: 1 broken invariant, 2s
```

### 3. Review the broken invariants

Each broken invariant is saved under `.ripfuzz/traces` with the full call
sequence and the failing check values:

```text
Logs:
  INV-02: count must stay small
    a: 100
    b: 100
```

Broken invariants are deduplicated by invariant id, so each id is reported once
with its shortest reproduction. Invariant functions that use handle-based
checks cannot be `view` because the checks call the ripfuzz VM.

## Scripts

Scripts run deterministic flows once with `ripfuzz exec`. A script inherits
`Script`, optionally defines `setup()`, and must define `exec()`:

Example: [`examples/ExampleScript.sol`](examples/ExampleScript.sol), run by
`make exec`.

```solidity
import {Script} from "ripfuzz/std.sol";

contract ExampleScript is Script {
    function exec() external {
        address alice = rvm.addr(1);
        rvm.label(alice, "alice");
        rvm.deal(alice, 100 ether);

        log("alice: ", alice);
        log("done");
    }
}
```

Run with:

```sh
ripfuzz exec examples/ExampleScript.sol
```

`log` output prints to the terminal and the execution trace is saved under
`.ripfuzz/traces`.

## Max

Max mode finds the largest reachable value of a harness `value()` function.
Inherit `Harness`, define `value()`, and run `ripfuzz max`:

```solidity
import {Harness} from "ripfuzz/std.sol";

contract ExampleMax is Harness {
    function value() external view returns (uint256) {
        // ...
    }
}
```

Run with:

```sh
ripfuzz max examples/ExampleMax.sol
```

## Cheatcodes

Harnesses, invariant tests, and scripts access ripfuzz cheatcodes through
`rvm`. Full list: [`src/RVM.sol`](src/RVM.sol).

```solidity
rvm.deal(user, 100 ether);
rvm.prank(user);
rvm.warp(block.timestamp + 1 days);
rvm.fork(rpcUrl, blockNumber);
```

## License

MIT
