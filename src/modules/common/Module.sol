// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import {Executor} from "./Executor.sol";
import {FactoryFriendly} from "./FactoryFriendly.sol";

struct ModuleStorage {
    /// @dev address that will execute the transaction.
    /// this is used for Safe moduleExec
    address avatar;
    address guard;
}

abstract contract Module is Executor, FactoryFriendly {
    function slot() internal pure virtual returns (ModuleStorage storage ms);

    function setAvatar(address _avatar) public onlyOwner {
        slot().avatar = _avatar;
    }

    function avatar() internal view returns (address) {
        return slot().avatar;
    }

    function guard() internal view returns (address) {
        return slot().guard;
    }
}
