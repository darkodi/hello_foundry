// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol"; //  A superset of DSTest containing standard libraries, a cheatcodes instance (vm), and Hardhat console

contract EmitContractTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function test_ExpectEmit() public {
        ExpectEmit emitter = new ExpectEmit();
        // Check that topic 1, topic 2, and data are the same as the following emitted event.
        // Checking topic 3 here doesn't matter, because `Transfer` only has 2 indexed topics.
        // The 4th argument in expectEmit is set to true, which means that we want to check "non-indexed topics", also known as data.
        vm.expectEmit(true, true, false, true);
        // The event we expect (from: address(this), to: address(1337))
        emit Transfer(address(this), address(1337), 1337);
        // The event we get
        emitter.t();
    }

    function test_ExpectEmit_DoNotCheckData() public {
        ExpectEmit emitter = new ExpectEmit();
        // Check topic 1 and topic 2, but do not check data
        vm.expectEmit(true, true, false, false); // we want to check the 1st and 2nd indexed topic for the next event.
        // The event we expect
        emit Transfer(address(this), address(1337), 1337); // 4th arg is not checked (false)
        // The event we get
        emitter.t();
    }
}

contract ExpectEmit {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function t() public {
        emit Transfer(msg.sender, address(1337), 1337);
    }
}
