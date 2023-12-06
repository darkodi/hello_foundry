// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";

// Examples of deal and hoax
// deal(address, uint) - Set balance of address
// hoax(address, uint) - deal + prank, Sets up a prank and set balance

contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet{value: 1e18}();
    }

    // It allows the contract to receive Ether.
    receive() external payable {}

    // Check how much ETH available for test
    function testEthBalance() public {
        console.log("ETH balance", address(this).balance / 1e18);
    }

    function _send(uint256 amount) private {
        (bool ok,) = address(wallet).call{value: amount}("");
        require(ok, "send ETH failed");
    }
     function testSendEth() public {
        uint256 bal = address(wallet).balance;

        // set balance to some address
        deal(address(1), 100);
        assertEq(address(1).balance, 100);

        deal(address(1), 10);
        assertEq(address(1).balance, 10);

        
        deal(address(1), 123); // balance[address 1] = 123
        vm.prank(address(1)); // msg.sender is address 1
        _send(123); // send 123 to wallet

        // the same thing could be achieved with hoax (deal + prank) 
        hoax(address(1), 456);
        _send(456); // send 456 to wallet

        assertEq(address(wallet).balance, bal + 123 + 456); // total balance
    }

}