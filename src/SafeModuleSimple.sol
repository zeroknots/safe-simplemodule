pragma solidity 0.8.19;

import {Module} from "zodiac/core/Module.sol";

import "forge-std/console2.sol";

contract SafeModuleSimple is Module {
    function fooCall() external {
        console2.log("fooCall");
        return 1337;
    }

    function fooDelegatecall() external {
        console2.log("fooDelegatecall");
        return 1338;
    }
}
