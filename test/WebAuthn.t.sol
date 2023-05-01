import "./setup/Setup.t.sol";
import "../src/SafeModuleSimple.sol";
import "../src/guards/SubGuardFunctionSigBlacklist.sol";

import "../src/modules/Webauthn/WebAuthn.sol";
import "../src/modules/ERC4337Diatomic/UserOperation.sol";

import "./setup/ERC4337.t.sol";

contract WebauthnTest is ERC4337Test {
    using SafeTestLib for SafeInstance;

    WebAuthn webauthn;

    function setUp() public override {
        super.setUp();
        webauthn = new WebAuthn();
    }

    function testERC4337() public {


      address receiver = makeAddr("receiver");

      address safeAccount = address(instance.safe);


      bytes memory callData;

      uint256 nonce = 0;


      bytes memory useropsDigest = erc4337Module.encodeOperationData({
        safe: safeAccount,
        callData: callData,
        nonce: nonce,
        verificationGas: 2e6,
        preVerificationGas: 2e6,
        maxFeePerGas: 1,
        maxPriorityFeePerGas: 1,
        callGas: 2e6,
        address: entrypoint,
      });




    }

    function testWebAuthn() public {
        // insert tests here
        address receiver = makeAddr("receiver");
        address account = address(instance.safe);

        // prepare signature to send funds
        (uint8 v, bytes32 r, bytes32 s) = instance.signTransaction(
            ownerPKs[0], receiver, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), address(0)
        );
        bytes memory signature = abi.encodePacked(r, s, v);

        bytes memory webauthnSig = abi.encode(
            keccak256(abi.encodePacked("test")), // keyHash
            uint256(0x7b1d4e87baa8ae41b3f2f054552c1dbb94fa2857924833fee90b56520976885b), // signature x coordinate
            uint256(0x41936d56ed7fba91313899b6578970170758090258d4a21b87d09dc3641baaa0), // signature y coordinate
            bytes.concat(
                bytes32(0xf95bc73828ee210f9fd3bbe72d97908013b0a3759e9aea3d0ae318766cd2e1ad), bytes5(0x0500000000)
            ), // authenticator data
            string('{"type":"webauthn.get","challenge":"'), // client data before challenge
            string('","origin":"https://webauthn.me","crossOrigin":false}') // client data after challenge
        );

        bytes memory execCallData = abi.encodeWithSelector(
            instance.safe.execTransaction.selector,
            receiver,
            0.5 ether,
            "",
            Enum.Operation.Call,
            0,
            0,
            0,
            address(0),
            address(0),
            signature
        );

        // prepare ERC4337 compliant userop
        UserOperation memory userOp = UserOperation({
            sender: entrypoint,
            nonce: 0,
            initCode: bytes(""),
            callData: abi.encodeWithSelector(instance.safe.execTransactionFromModule.selector, receiver, 1 ether, bytes("")), // send 1 ether to account1
            callGasLimit: 2e6,
            verificationGasLimit: 2e6,
            preVerificationGas: 2e6,
            maxFeePerGas: 1,
            maxPriorityFeePerGas: 1,
            paymasterAndData: bytes(""),
            signature: signature
        });

        vm.startPrank(entrypoint);
        erc4337Module.validateUserOp(userOp, "", 1);
        vm.stopPrank();
    }
}
