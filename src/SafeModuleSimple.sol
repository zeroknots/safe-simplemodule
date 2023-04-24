pragma solidity 0.8.19;

import {Module} from "zodiac/core/Module.sol";

import "forge-std/console2.sol";

contract SafeModuleSimple is Module {
    function setUp(bytes memory initParams) override public {}

    function fooCall() external returns (uint256) {
        console2.log("fooCall");
        return 1337;
    }

    function fooDelegatecall() external returns (uint256) {
        console2.log("fooDelegatecall");
        return 1338;
    }
}
