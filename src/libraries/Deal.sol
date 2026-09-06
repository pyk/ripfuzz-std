// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {IERC20} from "../interfaces/IERC20.sol";
import {RVM} from "../RVM.sol";

/// @title Deal
///
/// @dev Foundry-style deal helpers for ripfuzz harnesses.
///
/// @dev Sets ERC20 balances by locating the `balanceOf` slot through probing,
///      then writing storage directly with RVM `store` and `load`.
///
/// @dev Supports these layouts:
///      - Solidity: `keccak256(abi.encode(account, slot))`.
///      - Vyper: `keccak256(abi.encode(slot, account))`.
///      - Solady: `keccak256` of the owner and the fixed balance seed.
///
/// @dev Tokens that derive balances from packed structs or other off-mapping
///      state are not supported.
library Deal {
    // [*] Deal ===============================================================

    /// @dev Address used to probe candidate balance slots.
    address internal constant PROBE = address(uint160(0xbEEF));

    /// @dev Value written to candidate slots while probing. One wei above
    ///      `1e18` so an accidental balance match is implausible.
    uint256 internal constant SENTINEL = 1_000_000_000_000_000_001;

    /// @dev Number of candidate slots scanned per layout.
    uint256 internal constant MAX_SLOT = 64;

    /// @dev Solady ERC20 balance seed, the fixed suffix of the balance key.
    ///      See `Solady ERC20 _BALANCE_SLOT_SEED`.
    uint256 internal constant SOLADY_BALANCE_SEED = 0x87a211a2;

    // [*] RVM ================================================================

    address internal constant RVM_ADDRESS = address(uint160(uint256(keccak256("ripfuzz cheatcode"))));

    RVM internal constant rvm = RVM(RVM_ADDRESS);

    // [*] Layout =============================================================

    /// @dev How a token hashes `balances[account]`.
    enum Layout {
        Solidity,
        Vyper,
        Solady
    }

    /// @dev Set the ERC20 balance of `to` on `token` to `value`. Probes the
    ///      balance slot on every call. Reverts when the balance slot cannot
    ///      be found.
    /// @param token The ERC20 token.
    /// @param to The recipient account.
    /// @param value The new token balance.
    function deal(address token, address to, uint256 value) internal {
        (uint256 slot, Layout keyLayout) = findBalanceSlot(token);
        rvm.store(token, mappingKey(keyLayout, to, slot), bytes32(value));
    }

    /// @dev Set the ERC20 balance of `to` on `token` to `value` at a balance
    ///      slot found earlier with `findBalanceSlot`.
    /// @param token The ERC20 token.
    /// @param to The recipient account.
    /// @param value The new token balance.
    /// @param slot The mapping slot index of `balanceOf`.
    /// @param keyLayout The mapping key layout of `balanceOf`.
    function deal(address token, address to, uint256 value, uint256 slot, Layout keyLayout) internal {
        rvm.store(token, mappingKey(keyLayout, to, slot), bytes32(value));
    }

    // [*] Probe ==============================================================

    /// @dev Find the `balanceOf` mapping slot of `token`. Probes candidate
    ///      slots 0 to 63 for the sequential layouts, then the fixed Solady
    ///      key, and restores each probed slot afterwards. Reverts when no
    ///      candidate slot matches.
    /// @param token The ERC20 token.
    /// @return slot The mapping slot index, zero for the Solady layout.
    /// @return keyLayout The mapping key layout.
    function findBalanceSlot(address token) internal returns (uint256 slot, Layout keyLayout) {
        for (uint256 l; l < 3; l++) {
            Layout candidate = Layout(l);
            // The Solady key ignores the slot, so one probe decides it.
            uint256 max = candidate == Layout.Solady ? 1 : MAX_SLOT;
            for (uint256 s; s < max; s++) {
                bytes32 hashed = mappingKey(candidate, PROBE, s);
                bytes32 prev = rvm.load(token, hashed);
                rvm.store(token, hashed, bytes32(SENTINEL));
                bool found = probeBalance(token) == SENTINEL;
                rvm.store(token, hashed, prev);
                if (found) {
                    return (s, candidate);
                }
            }
        }
        revert("Deal: balance slot not found");
    }

    /// @dev Return the `balanceOf(PROBE)` value read through a static call, or
    ///      zero when the call fails or returns no word.
    /// @param token The ERC20 token.
    /// @return balance The probed balance.
    function probeBalance(address token) internal view returns (uint256 balance) {
        (bool success, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(IERC20.balanceOf.selector, PROBE));
        if (!success || data.length < 32) {
            return 0;
        }
        bytes32 raw;
        // Take the last 32-byte word; some tokens append extra return data.
        assembly {
            raw := mload(add(data, mload(data)))
        }
        balance = uint256(raw);
    }

    /// @dev Hash `account` and `slot` into the mapping storage key for
    ///      `keyLayout`. The Solady layout ignores `slot` and hashes the owner
    ///      against the fixed balance seed instead.
    /// @param keyLayout The mapping key layout.
    /// @param account The mapping key.
    /// @param slot The mapping slot index.
    /// @return The hashed storage slot.
    function mappingKey(Layout keyLayout, address account, uint256 slot) internal pure returns (bytes32) {
        if (keyLayout == Layout.Vyper) {
            return keccak256(abi.encode(slot, account));
        }
        if (keyLayout == Layout.Solady) {
            return keccak256(abi.encodePacked(account, bytes8(uint64(0)), bytes4(uint32(SOLADY_BALANCE_SEED))));
        }
        return keccak256(abi.encode(account, slot));
    }
}
