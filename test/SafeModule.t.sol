pragma solidity 0.8.19;

import "safe-tools/SafeTestTools.sol";
import "forge-std/Test.sol";

import "../src/SafeModuleSimple.sol";

contract SafeModuleTest is Test, SafeTestTools {
    using SafeTestLib for SafeInstance;

    SafeInstance safeInstance;

    SafeModuleSimple simpleModule;

    function setUp() public {
        safeInstance = _setupSafe();

        simpleModule = new SafeModuleSimple();
    }

    function testSendSimpleTransaction() public {
        address alice = address(0xA11c3);
        safeInstance.execTransaction({to: alice, value: 0.5 ether, data: ""}); // send .5 eth to alice

        assertEq(alice.balance, 0.5 ether); // passes ✅
    }

    function testEnableModule() public {
        address module = address(simpleModule);

        safeInstance.enableModule(module);
        assertTrue(safeInstance.safe.isModuleEnabled(module));
    }

    function testDisableModule() public {
        address module = address(simpleModule);

        safeInstance.enableModule(module);
        assertTrue(safeInstance.safe.isModuleEnabled(module));
        safeInstance.disableModule(module);
        assertFalse(safeInstance.safe.isModuleEnabled(module));
    }

    function testSignTransaction() public {
        address alice = address(0x1234);
        uint256[] memory ownerPKs = new uint256[](1);
        ownerPKs[0] = 12345;
        SafeInstance memory instance = _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});
        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], alice, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), address(0)
        );
        bytes memory signature = abi.encodePacked(r, s, v);
        instance.safe.execTransaction(
            alice, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), signature
        );
        assertEq(alice.balance, 0.5 ether);
    }

    function testExecModule() public {
        bytes memory functionOnModule = abi.encodeWithSelector(SafeModuleSimple.fooCall.selector);
        bytes memory execModule = abi.encodeWithSelector(
            ModuleManager.execTransactionFromModule.selector, address(simpleModule), 0, functionOnModule
        );

        address alice = address(0x1234);
        uint256[] memory ownerPKs = new uint256[](1);
        ownerPKs[0] = 12345;
        SafeInstance memory instance = _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});

        address module = address(simpleModule);
        instance.enableModule(module);
        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], alice, 0.5 ether, execModule, Enum.Operation.Call, 0, 0, 0, address(0), module
        );
        bytes memory signature = abi.encodePacked(r, s, v);
        instance.safe.execTransaction(
            alice, 0.5 ether, execModule, Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), signature
        );
        assertEq(alice.balance, 0.5 ether);
    }
}
