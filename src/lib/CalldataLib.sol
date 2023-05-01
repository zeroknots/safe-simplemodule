// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

error CalldataLength(uint256);

library CalldataLib {
    function getCalldata() internal pure returns (bytes4 functionSig, bytes memory callData) {
        assembly {
            let size := calldatasize()
            callData := mload(0x40)
            mstore(0x40, add(callData, add(size, 0x20)))
            calldatacopy(add(callData, 0x20), 0, size)
            mstore(callData, size)
            functionSig := mload(add(callData, 0x20))
        }
    }

    function extractSelector(bytes memory callData) internal pure returns (bytes4 functionSig) {
        if (callData.length < 4) revert CalldataLength(callData.length);
        assembly {
            functionSig := mload(add(callData, 0x20))
            functionSig := shl(224, functionSig)
            functionSig := shr(224, functionSig)
        }
    }

    function stripSelector(bytes memory callData) internal pure returns (bytes memory strippedCallData) {
        if (callData.length < 4) revert CalldataLength(callData.length);
        assembly {
            strippedCallData := add(callData, 0x20)
        }
    }
}
