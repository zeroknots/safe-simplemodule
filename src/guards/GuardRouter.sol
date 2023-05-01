// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.19;

import "@gnosis.pm/common/Enum.sol";
import "@gnosis.pm/base/GuardManager.sol";
import "@gnosis.pm/GnosisSafe.sol";

import "forge-std/console2.sol";

contract GuardRouter is Guard {
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
        // solhint-disable-next-line no-unused-vars
        address payable refundReceiver,
        bytes memory,
        address
    ) external view override {
        console2.log("checkTransaction");
        console2.logBytes(data);
    }

    function checkAfterExecution(bytes32, bool) external view override {}
}
