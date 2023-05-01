// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.19;

import "@gnosis.pm/common/Enum.sol";
import "@gnosis.pm/base/GuardManager.sol";
import "@gnosis.pm/GnosisSafe.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console2.sol";

import "../lib/CalldataLib.sol";

contract SubGuardFunctionSigBlacklist is Guard {
    using CalldataLib for bytes;

    mapping(bytes4 => bool) public blacklistedFunctionSigs;

    constructor() {}

    // solhint-disable-next-line payable-fallback
    fallback() external {
        // We don't revert on fallback to avoid issues in case of a Safe upgrade
        // E.g. The expected check method might change and then the Safe would be locked.
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory,
        address
    ) external override {
        bytes4 functionSig = CalldataLib.extractSelector(data);
        if (blacklistedFunctionSigs[functionSig]) {
            revert("Function signature is blacklisted");
        }
    }

    function checkAfterExecution(bytes32, bool) external view override {}

    function setBlacklistedFunctionSig(bytes4 _functionSig, bool _isBlacklisted) public {
        console2.log("Blacklisting:");
        console2.logBytes4(_functionSig);
        blacklistedFunctionSigs[_functionSig] = _isBlacklisted;
    }
}
