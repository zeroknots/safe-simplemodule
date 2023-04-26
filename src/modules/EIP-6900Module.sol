// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.4;

import "./common/Module.sol";

library LogicStorageLib {
    bytes32 constant logicSlot = keccak256("storage.location.moduleLogic");

    struct LogicStorage {
        uint256 foo;
        uint256 bar;
        uint256 baz;
    }

    function slot() internal pure returns (LogicStorage storage ls) {
        bytes32 loc = logicSlot;
        assembly {
            ls.slot := loc
        }
    }
}

abstract contract ModuleReferenceImplementation is Module {
    bytes32 constant moduleSlot = keccak256("storage.location.moduleConst");

    function setUp(bytes memory initializeParams) public override {
        // Do something with initializeParams
    }

    function slot() internal pure override(Module) returns (ModuleStorage storage ms) {
        bytes32 loc = moduleSlot;
        assembly {
            ms.slot := loc
        }
    }

    function setFoo(uint256 _foo) external {
        LogicStorageLib.LogicStorage storage ls = LogicStorageLib.slot();
        ls.foo = _foo;
    }
}
