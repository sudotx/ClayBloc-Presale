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

    // Methodology of Tests
    // the main objectives of this token presale contract is to allow users
    // participate

    function TestBuyTokens() external {}
    function TestBuyTokensFailUnsuccesfulTransfer() external {}
    function TestBuyTokensFailReenter() external {}
    function TestBuyTokensFailInvalidProof() external {}
    function TestBuyTokensFailZeroValue() external {}
    function TestBuyTokensFail() external {}
    function TestBuyTokensFailInvalidState() external {}
    function TestClaimTokensFailUserDepositedAndClaimed() external {}
    function TestClaimTokensFailVestingPeriodStillActive() external {}
    function TestClaimTokensInvalidCaller() external {}
    function TestClaimTokensFailReenter() external {}
    function TestClaimTokensFail() external {}
    function TestWithdrawEth() external {}
    function TestWithdrawEthFail() external {}
    function TestWithdrawTokens() external {}
    function TestWithdrawTokensFail() external {}
    function TestEthToToken() external {}
    function TestEthToTokenFail() external {}
    function TestUpdateEthPricePerToken() external {}
    function TestUpdateEthPricePerTokenFail() external {}
    function TestIncreaseHardCap() external {}
    function TestIncreaseHardCapFail() external {}
    function TestTransferOperatorOwnership() external {}
    function TestTransferOperatorOwnershipFail() external {}
    function TestUpdateWhitelist() external {}
    function TestUpdateWhitelistFail() external {}
    function TestsetVestingDuration() external {}
    function TestsetVestingDurationFail() external {}
}
