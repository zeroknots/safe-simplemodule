// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import {FactoryFriendly} from "./FactoryFriendly.sol";

struct ModuleStorage {
    /// @dev address that will execute the transaction.
    /// this is used for Safe moduleExec
    address avatar;
}

abstract contract Module is FactoryFriendly {
    function slot() internal pure virtual returns (ModuleStorage storage ms);

    function setAvatar(address _avatar) public onlyOwner {
        slot().avatar = _avatar;
    }

    /// @dev Passes a transaction to be executed by the avatar.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function exec(address to, uint256 value, bytes memory data, Enum.Operation operation)
        internal
        returns (bool success)
    {
        address currentGuard = guard;
        if (currentGuard != address(0)) {
            IGuard(currentGuard).checkTransaction(
                /// Transaction info used by module transactions.
                to,
                value,
                data,
                operation,
                /// Zero out the redundant transaction information only used for Safe multisig transctions.
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                msg.sender
            );
            success = IAvatar(target).execTransactionFromModule(to, value, data, operation);
            IGuard(currentGuard).checkAfterExecution(bytes32("0x"), success);
        } else {
            success = IAvatar(target).execTransactionFromModule(to, value, data, operation);
        }
        return success;
    }

    /// @dev Passes a transaction to be executed by the target and returns data.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function execAndReturnData(address to, uint256 value, bytes memory data, Enum.Operation operation)
        internal
        returns (bool success, bytes memory returnData)
    {
        address currentGuard = guard;
        if (currentGuard != address(0)) {
            IGuard(currentGuard).checkTransaction(
                /// Transaction info used by module transactions.
                to,
                value,
                data,
                operation,
                /// Zero out the redundant transaction information only used for Safe multisig transctions.
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                msg.sender
            );
            (success, returnData) = IAvatar(target).execTransactionFromModuleReturnData(to, value, data, operation);
            IGuard(currentGuard).checkAfterExecution(bytes32("0x"), success);
        } else {
            (success, returnData) = IAvatar(target).execTransactionFromModuleReturnData(to, value, data, operation);
        }
        return (success, returnData);
    }
}
