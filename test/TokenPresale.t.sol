// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenPresale} from "../src/TokenPresale.sol";

contract TestPS1 is Test {
    TokenPresale public presale;

    function setUp() public {
        presale = new TokenPresale(1, address(0), address(1), address(2));
        console2.log("address of the presale contract", address(presale));
    }

    function testBuyTokens() external {
        console2.log("address of the presale contract", address(presale));
    }

    function testBuyTokensFailUnsuccesfulTransfer() external {}
    function testBuyTokensFailReenter() external {}
    function testBuyTokensFailInvalidProof() external {}
    function testBuyTokensFailZeroValue() external {}
    function testBuyTokensFail() external {}
    function testBuyTokensFailInvalidState() external {}
    function testClaimTokensFailUserDepositedAndClaimed() external {}
    function testClaimTokensFailVestingPeriodStillActive() external {}
    function testClaimTokensInvalidCaller() external {}
    function testClaimTokensFailReenter() external {}
    function testClaimTokensFail() external {}
    function testWithdrawEth() external {}
    function testWithdrawEthFail() external {}
    function testWithdrawTokens() external {}
    function testWithdrawTokensFail() external {}
    function testEthToToken() external {}
    function testEthToTokenFail() external {}
    function testUpdateEthPricePerToken() external {}
    function testUpdateEthPricePerTokenFail() external {}
    function testIncreaseHardCap() external {}
    function testIncreaseHardCapFail() external {}
    function testTransferOperatorOwnership() external {}
    function testTransferOperatorOwnershipFail() external {}
    function testUpdateWhitelist() external {}
    function testUpdateWhitelistFail() external {}
    function testsetVestingDuration() external {}
    function testsetVestingDurationFail() external {}
}
