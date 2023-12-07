// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract InvariantIntro {
    bool public flag; // false 

    function func_1() external {}
    function func_2() external {}
    function func_3() external {}
    function func_4() external {}

    function func_5() external {
        flag = true; // change flag to true
    }
}

contract IntroInvariantTest is Test {
    InvariantIntro private target;

    function setUp() public {
        target = new InvariantIntro();
    }
    // invariant test should catch changing flag to true (func_5)
    function invariant_flag_is_always_false() public {
        assertEq(target.flag(), false); // expectation
    }
}