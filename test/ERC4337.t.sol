pragma solidity 0.8.19;

import "./Setup.t.sol";
import "../src/SafeModuleSimple.sol";
import "../src/guards/SubGuardFunctionSigBlacklist.sol";

// test specific imports

import {DoubleCheck4337Module} from "../src/modules/ERC4337Diatomic/EIP4337Module.sol";

contract GuardTest is SafeModuleTest {
    using SafeTestLib for SafeInstance;

    address entrypoint = makeAddr("entrypoint");

    function testDoubleERC4337() public {
        DoubleCheck4337Module erc4337Module = new DoubleCheck4337Module(entrypoint);

        instance.enableModule(address(erc4337Module));
    }
}
