pragma solidity 0.8.19;

import "./Setup.t.sol";
import "../../src/SafeModuleSimple.sol";
import "../../src/guards/SubGuardFunctionSigBlacklist.sol";

// test specific imports

import {Simple4337Module} from "../../src/modules/ERC4337Diatomic/EIP4337Module.sol";

contract ERC4337Test is SafeModuleTest {
    using SafeTestLib for SafeInstance;

    Simple4337Module erc4337Module;
    address entrypoint = makeAddr("entrypoint");

    function setUp() public virtual override {
        super.setUp();
        erc4337Module = new Simple4337Module(entrypoint);
        instance.enableModule(address(erc4337Module));
    }
}
