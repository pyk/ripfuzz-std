// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Base} from "./Base.sol";
import {Bound} from "./libraries/Bound.sol";
import {RVM} from "./RVM.sol";

/// @title Ripfuzz Harness
///
/// @dev Base contract for ripfuzz harnesses.
abstract contract Harness is Base {
    // [*] RVM ================================================================

    // [*] Actors =============================================================

    /// @dev Registered actors.
    address[] internal _actors;

    /// @dev Private key for each named actor created via `addActor(string)`.
    mapping(address => uint256) internal _actorPrivateKeys;

    /// @dev Actor selected by the active `useActor` modifier, if any.
    address internal currentActor;

    /// @dev Emitted when an actor is added.
    /// @param actor The added actor address.
    event ActorAdded(address actor);

    /// @dev Emitted when an actor is removed.
    /// @param actor The removed actor address.
    event ActorRemoved(address actor);

    // [*] Bound ==============================================================

    /// @dev Bound `x` between `min` and `max` (inclusive).
    /// @param x The value to bound.
    /// @param min The minimum bound (inclusive).
    /// @param max The maximum bound (inclusive).
    /// @return The bounded value.
    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        return Bound.bound(x, min, max);
    }

    // [*] Address ============================================================

    /// @dev Create a labeled address and private key derived from `name`.
    /// @param name Label used to derive the private key and set on the address.
    /// @return addr The derived address.
    /// @return privateKey The private key for `addr`.
    function createAddressAndKey(string memory name) internal returns (address addr, uint256 privateKey) {
        privateKey = uint256(keccak256(abi.encodePacked(name)));
        addr = rvm.addr(privateKey);
        rvm.label(addr, name);
    }

    /// @dev Create a labeled address derived from `name`.
    /// @param name Label used to derive the private key and set on the address.
    /// @return addr The derived address.
    function createAddress(string memory name) internal returns (address addr) {
        (addr,) = createAddressAndKey(name);
    }

    // [*] Actor management ===================================================

    /// @dev Prank as the actor at `actorId` for the duration of the function.
    ///      `actorId` is wrapped with modulo over the actor pool size.
    /// @param actorId Fuzzed actor index.
    modifier useActor(uint256 actorId) {
        address prevActor = currentActor;
        currentActor = getActor(actorId);
        rvm.startPrank(currentActor);
        _;
        rvm.stopPrank();
        currentActor = prevActor;
    }

    /// @dev Add `actor` to the pool.
    /// @param actor The address to add.
    function addActor(address actor) internal {
        _actors.push(actor);
        emit ActorAdded(actor);
    }

    /// @dev Create a labeled actor from `name`, store its private key, and add
    ///      it to the pool.
    /// @param name Actor label used to derive the address and private key.
    function addActor(string memory name) internal {
        (address actor, uint256 privateKey) = createAddressAndKey(name);
        _actorPrivateKeys[actor] = privateKey;
        addActor(actor);
    }

    /// @dev Return the private key for a named actor.
    /// @param actor The actor address.
    /// @return pk The actor private key.
    function getActorPrivateKey(address actor) internal view returns (uint256 pk) {
        pk = _actorPrivateKeys[actor];
        require(pk != 0, "getActorPrivateKey: not an actor");
    }

    /// @dev Remove `actor` from the pool. Reverts if it is not registered.
    /// @param actor The address to remove.
    function removeActor(address actor) internal {
        uint256 len = _actors.length;
        for (uint256 i = 0; i < len; i++) {
            if (_actors[i] == actor) {
                _actors[i] = _actors[len - 1];
                _actors.pop();
                delete _actorPrivateKeys[actor];
                emit ActorRemoved(actor);
                return;
            }
        }
        revert("removeActor: actor not found");
    }

    /// @dev Return the actor at `actorId`, wrapped with modulo over the pool.
    /// @param actorId Fuzzed actor index.
    /// @return actor The selected actor address.
    function getActor(uint256 actorId) internal view returns (address actor) {
        require(_actors.length > 0, "getActor: no actors");
        actor = _actors[actorId % _actors.length];
    }

    /// @dev Return the number of registered actors.
    /// @return count The actor pool size.
    function actorCount() internal view returns (uint256 count) {
        count = _actors.length;
    }
}
