// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdError} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        // executed before each test
        counter = new Counter();
        counter.setNumber(0);
    }

    function testFail_Decrement() public {
        // Foundry expects this test to fail (because of Fail word in the name), and it fails!
        counter.decrement();
    }

    function testDecrementUndeflow() public {
        vm.expectRevert(stdError.arithmeticError); // saying to foundry that we expect underflow error
        counter.decrement();
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
