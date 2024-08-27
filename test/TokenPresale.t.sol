// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {TokenPresale} from "src/TokenPresale.sol";
import {MockUSDC} from "test/Mocks/MockToken.sol";

contract ShmekmlesTest is Test {
    using stdJson for string;

    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint256 amount;
        uint256 id;
    }

    Result public result;
    User public user;
    bytes32 root = 0xeef4249e9125e40158057dcce3e6f1bda6a10d92dd2c76342c05aaaff87b6089;
    address user1 = 0x74a1c60568791C7BfD641E13B6941504E99437B2;

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

        // merkle = new Merkle(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(string.concat(".", vm.toString(user1)));
        user.user = vm.parseJsonAddress(dataJson, string.concat(".", vm.toString(user1), ".address"));
        user.amount = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".amount"));
        user.id = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".id"));
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);

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

    function testClaimed() public {
        // bool success = merkle.claim(user.user, user.amount, user.id, result.proof);
        // assertTrue(success);
    }

    function testAlreadyClaimed() public {
        // merkle.claim(user.user, user.amount, user.id, result.proof);
        vm.expectRevert("already claimed");
        // merkle.claim(user.user, user.amount, user.id, result.proof);
    }

    function testIncorrectProof() public {
        // bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        // merkle.claim(user.user, user.amount, user.id, fakeProofleaveitleaveit);
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
