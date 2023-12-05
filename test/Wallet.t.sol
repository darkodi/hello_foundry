// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

// forge test --match-path test/Auth.t.sol -vvvv

contract AuthTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet();
    }

    function testSetOwner() public {
        wallet.setOwner(address(1));
        assertEq(wallet.owner(), address(1));
    }

    function testFailNotOwner() public {
        // next call will be called by address(1)
        vm.prank(address(1));
        wallet.setOwner(address(1));
    }
}