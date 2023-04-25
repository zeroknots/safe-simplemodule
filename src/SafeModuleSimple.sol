pragma solidity 0.8.19;

import {Module} from "zodiac/core/Module.sol";

import "forge-std/console2.sol";

contract SafeModuleSimple is Module {
    function setUp(bytes memory initParams) public override {}

    function fooCall() external returns (uint256) {
        console2.log("fooCall, sender: %s, this: %s", msg.sender, address(this));
        return 1337;
    }
}
