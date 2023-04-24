pragma solidity 0.8.19;

import "safe-tools/SafeTestTools.sol";
import "forge-std/Test.sol";

contract SafeModuleTest is Test, SafeTestTools {
    using SafeTestLib for SafeInstance;

    SafeInstance safeInstance;

    function setUp() public {
        safeInstance = _setupSafe();
    }

    function testSendSimpleTransaction() public {
        address alice = address(0xA11c3);
        safeInstance.execTransaction({to: alice, value: 0.5 ether, data: ""}); // send .5 eth to alice

        assertEq(alice.balance, 0.5 ether); // passes ✅
    }

    function testEnableModule() public {
        address module = address(0x6969);

        safeInstance.enableModule(module);
        assertTrue(safeInstance.safe.isModuleEnabled(module));
    }

    function testDisableModule() public {
        address module = address(0x6969);

        safeInstance.enableModule(module);
        assertTrue(safeInstance.safe.isModuleEnabled(module));
        safeInstance.disableModule(module);
        assertFalse(safeInstance.safe.isModuleEnabled(module));
    }
}
