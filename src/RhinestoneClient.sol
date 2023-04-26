pragma solidity 0.8.19;

import {Module} from "zodiac/core/Module.sol";
import "safe-contracts/base/Executor.sol";
import "safe-contracts/common/Enum.sol";

import "forge-std/console2.sol";

library StorageLib {
    bytes32 constant RHINESTONE_CLIENT_STORAGE_POSITION = keccak256("zodiac.rhinestone.RhinestoneClient.storage");

    struct Storage {
        address registry;
        mapping(bytes4 functionSig => address) modules;
    }

    function storagePosition() internal pure returns (Storage storage ds) {
        bytes32 position = RHINESTONE_CLIENT_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

interface IModuleManager {
    function enableModule(address module) external;
}

contract RhinestoneClient is Executor, Module {
    function setUp(bytes memory initParams) public override {
        (address registry) = abi.decode(initParams, (address));
        StorageLib.storagePosition().registry = registry;
    }

    function installModule() external {}

    function installSafeModule() external {
        console2.log("installSafeModule");

        // check Rhienstone Registry
        // address module = ...
        // bytes4[] memory functionSigs = ...
        // IModuleManager(address(this)).enableModule(module);
        // StorageLib.storagePosition().modules[functionSig] = module;
    }

    // function getImpl(bytes4 functionSig) external returns (address module) {
    //     module = StorageLib.storagePosition().modules[functionSig];
    // }
}
