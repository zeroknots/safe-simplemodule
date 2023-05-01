// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import "@gnosis.pm/common/Enum.sol";
import "@gnosis.pm/base/GuardManager.sol";
import "@gnosis.pm/GnosisSafe.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "forge-std/console2.sol";

import "../lib/CalldataLib.sol";

contract GuardRouter is Guard {
    using CalldataLib for bytes;

    mapping(address to => address) subGuards;

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
        address subGuard = subGuards[to];
        console2.logBytes(data);

        // if subGuard for 'to' address is set. Forward this checkTransaction
        if (subGuards[to] != address(0)) {
            console2.log("Found subguard @: %s", subGuard);
            Guard(subGuard).checkTransaction(
                to, value, data, operation, safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, data, msg.sender
            );
        }
    }

    function checkAfterExecution(bytes32, bool) external view override {}

    function setSubGuard(address _to, address _guard) public {
        subGuards[_to] = _guard;
    }
}
