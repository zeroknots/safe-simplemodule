pragma solidity >=0.7.0 <0.9.0;

import "./Enum.sol";

abstract contract Executor {
    function exec(address to, uint256 value, bytes memory data, Enum.Operation operation)
        internal
        virtual
        returns (bool success);

    function execAndReturnData(address to, uint256 value, bytes memory data, Enum.Operation operation)
        internal
        virtual
        returns (bool success, bytes memory returnData);
}
