pragma solidity 0.8.19;

import "./setup/Setup.t.sol";
import "../src/SafeModuleSimple.sol";
import "../src/guards/SubGuardFunctionSigBlacklist.sol";

contract GuardTest is SafeModuleTest {
    using SafeTestLib for SafeInstance;

    function testSendEthWithGuardRouter() public {
        GuardRouter guard = new GuardRouter();
        setupGuard(address(guard));

        address alice = address(0x1234);

        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], alice, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), address(0)
        );
        bytes memory signature = abi.encodePacked(r, s, v);
        instance.safe.execTransaction(
            alice, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), signature
        );
        assertEq(alice.balance, 0.5 ether);
    }

    function testCallExternalWithguardRouter() public {
        // setup guard router
        GuardRouter guard = new GuardRouter();
        setupGuard(address(guard));

        // make instance of safe module
        address module = address(new SafeModuleSimple());
        // call fooCall fn on module
        bytes memory execModule = abi.encodeWithSelector(SafeModuleSimple.fooCall.selector);

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

    function testFailChainedGuards() public {
        // setup guard router
        GuardRouter guard = new GuardRouter();
        SubGuardFunctionSigBlacklist blacklist = new SubGuardFunctionSigBlacklist();
        address module = address(new SafeModuleSimple());

        setupGuard(address(guard));

        guard.setSubGuard(address(module), address(blacklist));
        blacklist.setBlacklistedFunctionSig(SafeModuleSimple.fooCall.selector, true);

        // make instance of safe module
        // call fooCall fn on module
        bytes memory execModule = abi.encodeWithSelector(SafeModuleSimple.fooCall.selector);

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
}
