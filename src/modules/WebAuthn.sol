// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;

import "../lib/Secp256r1.sol";
import "../lib/Base64.sol";

library WebAuthnLib {
    bytes32 constant NAMESPACE = "rhinestone.plugin.webauthn";
    bytes32 constant STORAGE_POSITION = keccak256(abi.encodePacked(NAMESPACE));

    struct WebAuthnStorage {
        mapping(bytes32 => PassKeyId) authorisedKeys;
        bytes32[] knownKeyHashes;
    }

    function storageReference() internal pure returns (WebAuthnStorage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }
}

contract WebAuthn {
    /* ----------------------------- EXTERNAL Functions ---------------------------------- */

    function addPassKey(bytes32 _keyHash, uint256 _pubKeyX, uint256 _pubKeyY, string calldata _keyId) external {
        emit PublicKeyAdded(_keyHash, _pubKeyX, _pubKeyY, _keyId);
        WebAuthnLib.storageReference().authorisedKeys[_keyHash] = PassKeyId(_pubKeyX, _pubKeyY, _keyId);
        WebAuthnLib.storageReference().knownKeyHashes.push(_keyHash);
    }

    function getAuthorisedKeys() external view returns (PassKeyId[] memory knownKeys) {
        knownKeys = new PassKeyId[](
            WebAuthnLib.storageReference().knownKeyHashes.length
        );
        for (uint256 i = 0; i < WebAuthnLib.storageReference().knownKeyHashes.length; i++) {
            knownKeys[i] =
                WebAuthnLib.storageReference().authorisedKeys[WebAuthnLib.storageReference().knownKeyHashes[i]];
        }
        return knownKeys;
    }

    function removePassKey(string calldata _keyId) external {
        require(WebAuthnLib.storageReference().knownKeyHashes.length > 1, "Cannot remove the last key");
        bytes32 keyHash = keccak256(abi.encodePacked(_keyId));
        PassKeyId memory passKey = WebAuthnLib.storageReference().authorisedKeys[keyHash];
        if (passKey.pubKeyX == 0 && passKey.pubKeyY == 0) {
            return;
        }
        delete WebAuthnLib.storageReference().authorisedKeys[keyHash];
        for (uint256 i = 0; i < WebAuthnLib.storageReference().knownKeyHashes.length; i++) {
            if (WebAuthnLib.storageReference().knownKeyHashes[i] == keyHash) {
                WebAuthnLib.storageReference().knownKeyHashes[i] = WebAuthnLib.storageReference().knownKeyHashes[WebAuthnLib
                    .storageReference().knownKeyHashes.length - 1];
                WebAuthnLib.storageReference().knownKeyHashes.pop();
                break;
            }
        }
        emit PublicKeyRemoved(keyHash, passKey.pubKeyX, passKey.pubKeyY, passKey.keyId);
    }

    function verifyPasskeySignature(UserOperation calldata userOp, bytes32 userOpHash) external returns (bool) {
        (
            bytes32 keyHash,
            uint256 sigx,
            uint256 sigy,
            bytes memory authenticatorData,
            string memory clientDataJSONPre,
            string memory clientDataJSONPost
        ) = abi.decode(userOp.signature, (bytes32, uint256, uint256, bytes, string, string));
        string memory opHashBase64 = Base64.encode(bytes.concat(userOpHash));
        string memory clientDataJSON = string.concat(clientDataJSONPre, opHashBase64, clientDataJSONPost);
        bytes32 clientHash = sha256(bytes(clientDataJSON));
        bytes32 sigHash = sha256(bytes.concat(authenticatorData, clientHash));

        PassKeyId memory passKey = WebAuthnLib.storageReference().authorisedKeys[keyHash];
        require(passKey.pubKeyY != 0 && passKey.pubKeyY != 0, "Key not found");
        require(Secp256r1.Verify(passKey, sigx, sigy, uint256(sigHash)), "Invalid signature");
        return true;
    }

    /* -------------------------------- IRhinestonePlugin -------------------------------- */

    function namespace() external pure returns (bytes32) {
        return WebAuthnLib.NAMESPACE;
    }

    /* ------------------------------------- EVENTS -------------------------------------- */
    event PublicKeyAdded(bytes32 indexed keyHash, uint256 pubKeyX, uint256 pubKeyY, string keyId);
    event PublicKeyRemoved(bytes32 indexed keyHash, uint256 pubKeyX, uint256 pubKeyY, string keyId);
}
