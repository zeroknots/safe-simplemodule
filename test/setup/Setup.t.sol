pragma solidity ^0.8.19;

import "safe-tools/SafeTestTools.sol";
import "forge-std/Test.sol";

import "../../src/SafeModuleSimple.sol";
import "../../src/RhinestoneClient.sol";
import "@gnosis.pm/base/GuardManager.sol";
import "../../src/guards/GuardRouter.sol";

abstract contract SafeModuleTest is Test, SafeTestTools {
    using SafeTestLib for SafeInstance;

    SafeInstance instance;

    SafeModuleSimple simpleModule;
    uint256[] ownerPKs;

    function setUp() public virtual {
        // setup private keys of owners
        instance = setupSafe();
    }

    function setupSafe() internal returns (SafeInstance memory) {
        // setup private keys of owners
        ownerPKs = new uint256[](1);
        ownerPKs[0] = 12345;
        return _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});
    }

    function setupGuard(address guard) internal {
        bytes memory exec_setGuard = abi.encodeWithSelector(GuardManager.setGuard.selector, guard);

        // sign transaction to setGuard
        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], address(instance.safe), 0, exec_setGuard, Enum.Operation.Call, 0, 0, 0, address(0), address(0)
        );
        // get signature
        bytes memory signature = abi.encodePacked(r, s, v);

        // exec setGuard
        instance.safe.execTransaction(
            address(instance.safe),
            0,
            exec_setGuard,
            Enum.Operation.Call,
            0,
            0,
            0,
            address(0),
            payable(address(0)),
            signature
        );
    }
}
