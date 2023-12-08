// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {WETH} from "src/WETH.sol";


import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

// we want to test WETH functions (deposit and withdraw) under specific conditions
// Handler contract is a wrapper around WETH
contract Handler is CommonBase, StdCheats, StdUtils {
    WETH private weth;
    uint256 public wethBalance; // amount that's deposited to WETH contract from this contract
    uint256 public numCalls;

    constructor(WETH _weth) {
        weth = _weth;
    }
    // falback, to be able to receive ETH 
    receive() external payable {}

    function sendToFallback(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        numCalls += 1;

        (bool ok,) = address(weth).call{value: amount}(""); // direct transfer of amount to weth contract
        require(ok, "sendToFallback failed");
    }

    function deposit(uint256 amount) public {
        amount = bound(amount, 0, address(this).balance);
        wethBalance += amount;
        numCalls += 1;

        weth.deposit{value: amount}(); // call to weth's deposit
    }

    function withdraw(uint256 amount) public {
        amount = bound(amount, 0, weth.balanceOf(address(this))); // weth balance of Handler contract
        wethBalance -= amount;
        numCalls += 1;

        weth.withdraw(amount);
    }

    function fail() external pure { // this function is not called by the foundry (it's not part of the targetSelector)
        revert("fail");
    }
}

contract WETH_Handler_Based_Invariant_Tests is Test {
    WETH public weth;
    Handler public handler;

    function setUp() public {
        weth = new WETH();
        handler = new Handler(weth);

        // Send 100 ETH to handler
        deal(address(handler), 100 * 1e18);
        // Set fuzzer to only call the handler!!! 
        // And not to call weth directly
        targetContract(address(handler));

        
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = Handler.deposit.selector;
        selectors[1] = Handler.withdraw.selector;
        selectors[2] = Handler.sendToFallback.selector;
        //selectors[3] = Handler.fail.selector; // Handler.fail() not called
        
        // this is used to target specific functions for the random execution by the Foundry
        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
    }

    function invariant_eth_balance() public {
        // amount of eth that's locked inside weth contract >= amount of eth that was deposited from the Handler contract
        assertGe(address(weth).balance, handler.wethBalance());
        console.log("handler num calls", handler.numCalls());
    }
}