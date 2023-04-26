// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import "./Executor.sol";
import "./Module.sol";

abstract contract DiamondExecutor is Executor, Module {
    /// @dev Passes a transaction to be executed by the avatar.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function exec(address to, uint256 value, bytes memory data, Enum.Operation operation)
        internal
        override
        returns (bool success)
    {
        return true;
    }

    /// @dev Passes a transaction to be executed by the target and returns data.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function execAndReturnData(address to, uint256 value, bytes memory data, Enum.Operation operation)
        internal
        override
        returns (bool success, bytes memory returnData)
    {
        bytes memory ret = "0x1234";
        return (true, ret);
    }
}
