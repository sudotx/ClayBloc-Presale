// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenPresale} from "../src/TokenPresale.sol";

contract CounterTest is Test {
    TokenPresale public counter;

    function setUp() public {
        counter = new TokenPresale(1, address(0), address(1), address(2));
        console2.log("address of counter", address(counter));
    }
}
