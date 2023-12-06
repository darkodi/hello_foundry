// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Error} from "../src/Error.sol";

contract ErrorTest is Test {
    Error public err;

    function setUp() public {
        err = new Error();
    }

    function testFail() public { // has "fail" in the name
        err.throwError();
    }

    function testRevert() public {
        vm.expectRevert(); // cheatcode to tell foundry to expect revert from the next call
        err.throwError();
    }

    function testRequireMessage() public {
        vm.expectRevert(bytes("not authorized")); // revert with specific message
        err.throwError();
    }

    function testCustomError() public {
        vm.expectRevert(Error.NotAuthorized.selector); // revert with custom error
        err.throwCustomError();
    }

    // Add label to assertions
    function testErrorLabel() public {
        assertEq(uint256(1), uint256(1), "test 1");
        assertEq(uint256(1), uint256(1), "test 2");
        assertEq(uint256(1), uint256(1), "test 3");
        assertEq(uint256(1), uint256(1), "test 4");
        assertEq(uint256(1), uint256(1), "test 5");
    }
}