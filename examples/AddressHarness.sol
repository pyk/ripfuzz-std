// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Harness} from "ripfuzz/Harness.sol";

/// @title AddressHarness
///
/// @dev Example of `createAddress` and `createAddressAndKey`.
contract AddressHarness is Harness {
    address user;
    address signer;
    uint256 signerKey;

    /// @dev Create labeled addresses used by later checks.
    function setup() external {
        user = createAddress("user");
        (signer, signerKey) = createAddressAndKey("signer");
    }

    /// @dev Touch state so the campaign has a handler.
    function ping() external {}

    /// @dev Invariant: named addresses are non-zero and distinct.
    function invariant_AddressesAreDistinct() external {
        ensure(user != address(0), "user is non-zero");
        ensure(signer != address(0), "signer is non-zero");
        neq(user, signer, "user and signer differ");
    }

    /// @dev Invariant: stored key derives back to `signer`.
    function invariant_KeyMatchesSigner() external {
        eq(rvm.addr(signerKey), signer, "private key matches signer");
    }

    /// @dev Invariant: labels were applied.
    function invariant_LabelsAreSet() external {
        // Compared as strings via ensure on equality of hashes.
        ensure(keccak256(bytes(rvm.getLabel(user))) == keccak256(bytes("user")), "user label");
        ensure(keccak256(bytes(rvm.getLabel(signer))) == keccak256(bytes("signer")), "signer label");
    }
}
