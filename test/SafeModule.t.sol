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
        address module = address(simpleModule);
        vm.label(module, "SimpleModule");
        console2.log("SimpleModule@ ", module);

        bytes memory execModule = abi.encodeWithSelector(SafeModuleSimple.fooCall.selector);

        address alice = address(0x1234);
        uint256[] memory ownerPKs = new uint256[](1);
        ownerPKs[0] = 12345;

        SafeInstance memory instance = _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});
        instance.enableModule(module);
        console2.log("SafeInstance @ %s", address(instance.safe));

        // prepare signature for transaction
        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], module, 0, execModule, Enum.Operation.Call, 0, 0, 0, address(0), address(0)
        );
        bytes memory signature = abi.encodePacked(r, s, v);

        // exec transaction
        instance.safe.execTransaction(
            module, 0, execModule, Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), signature
        );
    }


    function testExecModuleDelegate() public {
        address module = address(simpleModule);
        vm.label(module, "SimpleModule");
        console2.log("SimpleModule@ ", module);

        bytes memory execModule = abi.encodeWithSelector(SafeModuleSimple.fooCall.selector);

        address alice = address(0x1234);
        uint256[] memory ownerPKs = new uint256[](1);
        ownerPKs[0] = 12345;

        SafeInstance memory instance = _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});
        instance.enableModule(module);
        console2.log("SafeInstance @ %s", address(instance.safe));

        // prepare signature for transaction
        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], module, 0, execModule, Enum.Operation.DelegateCall, 0, 0, 0, address(0), address(0)
        );
        bytes memory signature = abi.encodePacked(r, s, v);

        // exec transaction
        instance.safe.execTransaction(
            module, 0, execModule, Enum.Operation.DelegateCall, 0, 0, 0, address(0), payable(address(0)), signature
        );
    }
}
