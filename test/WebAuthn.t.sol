import "./Setup.t.sol";
import "../src/SafeModuleSimple.sol";
import "../src/guards/SubGuardFunctionSigBlacklist.sol";

import "../src/modules/WebAuthn.sol";
import "../src/modules/ERC4337Diatomic/UserOperation.sol";

contract WebauthnTest is SafeModuleTest {
    using SafeTestLib for SafeInstance;

    WebAuthn webauthn;

    function setUp() public override {
        super.setUp();
        webauthn = new WebAuthn();
    }

    function testWebAuthn() public {
        // insert tests here
        address receiver = makeAddr("receiver");
        address account = address(instance.safe);

        UserOperation memory userOp = UserOperation({
            sender: account,
            nonce: 0,
            initCode: bytes(""),
            callData: abi.encodeWithSelector(instance.safe.execTransaction.selector, receiver, 1 ether, bytes("")), // send 1 ether to account1
            callGasLimit: 2e6,
            verificationGasLimit: 2e6,
            preVerificationGas: 2e6,
            maxFeePerGas: 1,
            maxPriorityFeePerGas: 1,
            paymasterAndData: bytes(""),
            signature: abi.encode(
                keccak256(abi.encodePacked("test")), // keyHash
                uint256(0x7b1d4e87baa8ae41b3f2f054552c1dbb94fa2857924833fee90b56520976885b), // signature x coordinate
                uint256(0x41936d56ed7fba91313899b6578970170758090258d4a21b87d09dc3641baaa0), // signature y coordinate
                bytes.concat(
                    bytes32(0xf95bc73828ee210f9fd3bbe72d97908013b0a3759e9aea3d0ae318766cd2e1ad), bytes5(0x0500000000)
                ), // authenticator data
                string('{"type":"webauthn.get","challenge":"'), // client data before challenge
                string('","origin":"https://webauthn.me","crossOrigin":false}') // client data after challenge
            )
        });


        vm.startPrank(entrypoint);

    }
}
