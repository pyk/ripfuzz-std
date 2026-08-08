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

## Example

End-to-end smoke harness:
[`examples/CounterHarness.sol`](examples/CounterHarness.sol).

```solidity
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

    function setup() external {
        addActor("user");
        address user = getActor(0);
        rvm.deal(user, 100 ether);

        rvm.prank(user);
        counter = new Counter();
    }

    function increment(uint256 actorId) external useActor(actorId) {
        counter.increment();
    }

    function add(uint256 actorId, uint256 x) external useActor(actorId) {
        x = bound(x, 1, 100);
        counter.add(x);
    }

    function invariant_OwnerIsUser() external {
        eq(counter.owner(), getActor(0), "owner is user");
    }

    function invariant_CountStaysBounded() external {
        ensure(counter.count() < 1_000_000, "count stayed below 1_000_000");
    }
}
```

Run with:

```sh
ripfuzz run CounterHarness
```

## Usage

Inherit `Harness` to get cheatcodes, helpers, and assertions:

```solidity
import {Harness} from "ripfuzz/Harness.sol";

contract MyHarness is Harness {
    // ...
}
```

Each feature has a runnable example under `examples/`.

### Cheatcodes

Example: [`examples/CheatcodesHarness.sol`](examples/CheatcodesHarness.sol)

Access ripfuzz cheatcodes through `rvm`. Full list:
[`src/RVM.sol`](src/RVM.sol).

```solidity
rvm.deal(user, 100 ether);
rvm.prank(user);
rvm.warp(block.timestamp + 1 days);
```

### Environment variables

Example: [`examples/GetEnvHarness.sol`](examples/GetEnvHarness.sol)

Read process environment variables, including values from a project `.env`
file:

```solidity
// Required: reverts when the key is missing.
string memory rpcUrl = rvm.getEnv("ETH_RPC_URL");

// Optional: returns defaultValue when the key is missing.
string memory network = rvm.getEnv("NETWORK", "local");
```

### Addresses

Example: [`examples/AddressHarness.sol`](examples/AddressHarness.sol)

Create labeled addresses derived from a name:

```solidity
address user = createAddress("user");
(address signer, uint256 privateKey) = createAddressAndKey("signer");
```

### Actors

Example: [`examples/ActorsHarness.sol`](examples/ActorsHarness.sol)

Manage a pool of fuzz actors and prank as one per handler call:

```solidity
function setup() external {
    addActor("Alice");
    addActor("Bob");
}

function act(uint256 actorId, uint256 x) external useActor(actorId) {
    // msg.sender == currentActor for this call
    target.doThing(x);
}
```

| Helper                      | Purpose                                        |
| :-------------------------- | :--------------------------------------------- |
| `getActor(actorId)`         | Actor at index, wrapped with modulo            |
| `actorCount()`              | Pool size                                      |
| `getActorPrivateKey(actor)` | Key for actors created with `addActor(string)` |
| `removeActor(actor)`        | Remove from the pool                           |
| `currentActor`              | Actor selected by the active `useActor`        |

### Bound

Example: [`examples/BoundHarness.sol`](examples/BoundHarness.sol)

Clamp fuzz inputs into an inclusive range:

```solidity
x = bound(x, 1, 100);
```

### Logging

Example: [`examples/LoggingHarness.sol`](examples/LoggingHarness.sol)

Emit structured logs from handlers and assertions:

```solidity
log("deposit");
log("amount", amount);
log("user", user);
```

### Assertions

Example: [`examples/AssertionsHarness.sol`](examples/AssertionsHarness.sol)

Fail the campaign with a logged message:

```solidity
ensure(ok, "operation succeeded");
eq(a, b, "balances match");
neq(a, b, "ids differ");
unreachable("should never reach this path");
```

### Tokens

Example: [`examples/TokensHarness.sol`](examples/TokensHarness.sol)

Optional ERC20 helpers for non-standard tokens:

```solidity
import {IERC20} from "ripfuzz/interfaces/IERC20.sol";
import {SafeERC20} from "ripfuzz/libraries/SafeERC20.sol";

using SafeERC20 for IERC20;

token.safeApprove(spender, amount);
token.safeTransfer(to, amount);
```

### Fork

Example: [`examples/ForkHarness.sol`](examples/ForkHarness.sol)

Load the RPC URL from the environment (including a project `.env` file), then
fork and interact with a live contract such as USDC:

```solidity
// .env
// ETH_RPC_URL=https://eth.meowrpc.com

string memory rpcUrl = rvm.getEnv("ETH_RPC_URL", "https://eth.meowrpc.com");
rvm.fork(rpcUrl, 25_708_159);

IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
rvm.label(address(usdc), "USDC");

// Fund an actor by writing the FiatToken balances mapping (slot 9).
bytes32 slot = keccak256(abi.encode(alice, uint256(9)));
rvm.store(address(usdc), slot, bytes32(uint256(1_000_000e6)));

usdc.safeTransfer(bob, amount);
```

### Multi-fork

Example: [`examples/MultiForkHarness.sol`](examples/MultiForkHarness.sol)

Load per-chain RPC URLs once in `setup`, then use modifiers to select forks:

```solidity
// .env
// ETH_RPC_URL=https://eth.meowrpc.com
// BASE_RPC_URL=https://base.meowrpc.com

string internal ethRpcUrl;
string internal baseRpcUrl;

function setup() external {
    ethRpcUrl = rvm.getEnv("ETH_RPC_URL", "https://eth.meowrpc.com");
    baseRpcUrl = rvm.getEnv("BASE_RPC_URL", "https://base.meowrpc.com");
    // ...
}

modifier onEthereum() {
    rvm.fork(ethRpcUrl, 25_708_159);
    _;
}

modifier onBase() {
    rvm.fork(baseRpcUrl, 49_688_843);
    _;
}

function transferEthUsdc(uint256 actorId, uint256 amount)
    external
    onEthereum
    useActor(actorId)
{
    ethUsdc.safeTransfer(getActor(actorId + 1), amount);
}
```

## License

MIT
