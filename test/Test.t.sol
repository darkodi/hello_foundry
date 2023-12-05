// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract ContractBTest is Test {
    uint256 testNumber;

    function setUp() public {
        // An optional function invoked before each test case is run
        testNumber = 42;
    }
    // Functions prefixed with test are run as a test case.

    function test_NumberIs42() public {
        assertEq(testNumber, 42);
    }
    // testFail: The inverse of the test prefix - if the function does not revert, the test fails

    function testFail_Subtract43() public {
        testNumber -= 43;
    }
    // A good practice is to use the pattern test_Revert[If|When]_Condition in combination with the expectRevert cheatcode

    function test_CannotSubtract43() public {
        vm.expectRevert(stdError.arithmeticError);
        testNumber -= 43;
    }
}
