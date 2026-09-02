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

## Max

Max mode answers "how large can this value get?". It generates sequences of
handler calls, measures a `value()` function after every call, and reports the
highest value found with the shortest sequence that produced it. Use it to
validate limits and caps: the reported maximum shows whether a bound is tight
or unreachable.

A max harness inherits `Harness`, defines handlers and one `value()` function,
and must not declare `invariant_*` functions:

Example: [`examples/ExampleMax.sol`](examples/ExampleMax.sol), run by
`make max`.

```solidity
import {Harness} from "ripfuzz/std.sol";

contract ExampleMax is Harness {
    function setup() external {
        // Deploy the target and register actors.
    }

    function accrue(uint256 actorId, uint256 x) external useActor(actorId) {
        x = bound(x, 1, 10);
        accumulator.accrue(x);
    }

    function value() external view returns (uint256) {
        // ...
    }
}
```

The `value` function takes no arguments, returns exactly one `uint256`, and
must be `view` or `pure`. Read harness state with plain Solidity: calling
cheatcodes inside `value` is not supported.

Run with:

```sh
ripfuzz max examples/ExampleMax.sol
```

The campaign climbs toward the maximum and reports each improvement:

```text
initial value 0 measured for examples/ExampleMax.sol:ExampleMax
found best sequence: value 100, 11 calls
found best sequence: value 199, 20 calls
shrinking finished: 20 calls, 10001 attempts, 3s
```

For the example accumulator, twenty `accrue` calls of at most `10` each reach
`200`, so the campaign converges to `value 200` with a 20-call sequence: the
bound is tight. The best sequence is saved under `.ripfuzz/traces` for replay.

## Scripts

Scripts run a deterministic flow once with `ripfuzz exec`: replay a position
against a fork, verify a strategy, or reproduce a sequence found by `test` or
`max`. A script inherits `Script`, optionally defines `setup()`, and must
define `exec()`:

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

The `log` output prints to the terminal and the execution trace is saved under
`.ripfuzz/traces`:

```text
script examples/ExampleScript.sol:ExampleScript deployed at 0xD1c9...cd22
  alice: 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
  done
execution trace for examples/ExampleScript.sol:ExampleScript saved
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
