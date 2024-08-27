// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console2, stdJson} from "forge-std/Test.sol";

// import {Merkle} from "../src/AbegToken.sol";

// contract AbegTest is Test {
//     using stdJson for string;

//     Merkle public merkle;

//     struct Result {
//         bytes32 leaf;
//         bytes32[] proof;
//     }

//     struct User {
//         address user;
//         uint256 amount;
//         uint256 id;
//     }

//     Result public result;
//     User public user;
//     bytes32 root = 0xeef4249e9125e40158057dcce3e6f1bda6a10d92dd2c76342c05aaaff87b6089;
//     address user1 = 0x74a1c60568791C7BfD641E13B6941504E99437B2;

//     function setUp() public {
//         merkle = new Merkle(root);
//         string memory _root = vm.projectRoot();
//         string memory path = string.concat(_root, "/merkle_tree.json");

//         string memory json = vm.readFile(path);
//         string memory data = string.concat(_root, "/address_data.json");

//         string memory dataJson = vm.readFile(data);

//         bytes memory encodedResult = json.parseRaw(string.concat(".", vm.toString(user1)));
//         user.user = vm.parseJsonAddress(dataJson, string.concat(".", vm.toString(user1), ".address"));
//         user.amount = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".amount"));
//         user.id = vm.parseJsonUint(dataJson, string.concat(".", vm.toString(user1), ".id"));
//         result = abi.decode(encodedResult, (Result));
//         console2.logBytes32(result.leaf);
//     }

//     function testClaimed() public {
//         bool success = merkle.claim(user.user, user.amount, user.id, result.proof);
//         assertTrue(success);
//     }

//     function testAlreadyClaimed() public {
//         merkle.claim(user.user, user.amount, user.id, result.proof);
//         vm.expectRevert("already claimed");
//         merkle.claim(user.user, user.amount, user.id, result.proof);
//     }

//     function testIncorrectProof() public {
//         bytes32[] memory fakeProofleaveitleaveit;

//         vm.expectRevert("not whitelisted");
//         merkle.claim(user.user, user.amount, user.id, fakeProofleaveitleaveit);
//     }
// }
