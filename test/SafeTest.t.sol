// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Safe {
    // executed from outside the contract when the contract receives Ether directly without any data
    receive() external payable {} 

    // transfers all the Ether held by the contract (address(this).balance) to the sender (msg.sender).
    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract SafeTest is Test {
    Safe safe;

    // Needed so the test contract itself can receive ether
    // when withdrawing
    receive() external payable {}

    function setUp() public {
        safe = new Safe();
    }
    

    function test_Withdraw() public {
        payable(address(safe)).transfer(1 ether); // sends 1 Ether to the Safe contract
        uint256 preBalance = address(this).balance; // 0 Eth, balance of SafeTest contract
        safe.withdraw(); // transfer 1 Eth from Safe to SafeTest
        uint256 postBalance = address(this).balance; // 1 Eth
        assertEq(preBalance + 1 ether, postBalance);
    }

    // The general property: given a safe balance, when we withdraw, we should get whatever is in the safe.
    // fails if amount is > uint96
     function testFuzz_Withdraw(uint96 amount) public {

        vm.assume(amount > 0.1 ether); // exclude certain cases
        payable(address(safe)).transfer(amount);
        uint256 preBalance = address(this).balance;
        safe.withdraw();
        uint256 postBalance = address(this).balance;
        assertEq(preBalance + amount, postBalance);
    }
}

