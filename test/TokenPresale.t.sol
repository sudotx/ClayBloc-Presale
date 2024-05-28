// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenPresale} from "src/TokenPresale.sol";

import {MockUSDC} from "test/Mocks/MockToken.sol";

contract TestPS1 is Test {
    TokenPresale public presale;
    MockUSDC public token;
    address public protocolVault;
    address public uniswapV2Vault;
    address public deployer;
    address public alice;
    address public bob;
    address public chad;

    function setUp() public {
        uniswapV2Vault = address(69);
        protocolVault = makeAddr("Vault");

        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        chad = makeAddr("Chad");
        deployer = makeAddr("Deployer");

        vm.prank(deployer);
        presale = new TokenPresale(100, protocolVault, msg.sender, uniswapV2Vault);
        assertEq(presale.owner(), deployer);
        vm.stopPrank();
    }

    function testBuyTokens() external {
        // console2.log("address of the presale contract", address(presale));
        // bytes32[] calldata a;
        // presale.buyTokens{value: 0.5 ether}(a);
    }

    function testBuyTokensFailUnsuccesfulTransfer() external {
        vm.roll(presale.endDate() + presale.vestingDuration());
        presale.totalPurchasedAmount();
    }

    function testBuyTokensFailReenter() external {}
    function testBuyTokensFailInvalidProof() external {}
    function testBuyTokensFailZeroValue() external {}
    function testBuyTokensFail() external {}
    function testBuyTokensFailInvalidState() external {}
    function testClaimTokensFailUserDepositedAndClaimed() external {}
    function testClaimTokensFailVestingPeriodStillActive() external {}

    function testClaimTokensInvalidCaller() external {
        presale.claimTokens();
    }

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
