// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenPresale} from "src/TokenPresale.sol";

import {MockUSDC} from "test/Mocks/MockToken.sol";

contract TestPS1 is Test {
    TokenPresale public presale;
    MockUSDC public token;
    address public protocolVault;
    address public deployer;
    address public alice;
    address public bob;
    address public chad;

    address constant uniswapV2Factory = address(69);
    address constant uniswapV2Router = address(69);
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function setUp() public {
        token = new MockUSDC();
        console2.log("The address of the token is", address(token));
        token.mint(INITIAL_SUPPLY);

        protocolVault = makeAddr("Vault");

        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        chad = makeAddr("Chad");
        deployer = makeAddr("Deployer");

        vm.prank(deployer);
        presale = new TokenPresale(INITIAL_SUPPLY, protocolVault, uniswapV2Factory, uniswapV2Router, WETH);
        vm.label(address(presale), "presale");
        vm.label(address(this), "admin");
        assertEq(presale.owner(), deployer);
        vm.stopPrank();
    }

    function testClaimTokens() private {
        // vm.roll(presale.endDate() + 1);
        presale.claimTokens();
    }

    function testClaimTokensFailUserDepositedAndClaimed() external {
        testClaimTokens();
        // assert cases
    }

    // function testClaimTokensFailVestingPeriodStillActive() external {}

    // function testClaimTokensInvalidCaller() external {}

    // function testClaimTokensFailReenter() external {}
    // function testClaimTokensFail() external {}
    // function testWithdrawEth() external {}
    // function testWithdrawEthFail() external {}
    // function testWithdrawTokens() external {}
    // function testWithdrawTokensFail() external {}
    // function testEthToToken() external {}
    // function testEthToTokenFail() external {}
    // function testUpdateEthPricePerToken() external {}
    // function testUpdateEthPricePerTokenFail() external {}
    // function testIncreaseHardCap() external {}
    // function testIncreaseHardCapFail() external {}
    // function testTransferOperatorOwnership() external {}
    // function testTransferOperatorOwnershipFail() external {}
    // function testUpdateWhitelist() external {}
    // function testUpdateWhitelistFail() external {}
    // function testsetVestingDuration() external {}
    // function testsetVestingDurationFail() external {}
}
