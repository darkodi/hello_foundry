// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {WETH} from "../../src/WETH.sol";

// https://book.getfoundry.sh/forge/invariant-testing?highlight=targetSelector#invariant-targets
// https://mirror.xyz/horsefacts.eth/Jex2YVaO65dda6zEyfM_-DXlXhOWCAoSpOx5PLocYgw

// NOTE: open testing - randomly call all public functions
contract WETH_Open_Invariant_Tests is Test {
    WETH public weth;

    function setUp() public {
        weth = new WETH();
    }

    receive() external payable {}

    // NOTE: - calls = runs x depth, (runs, calls, reverts)
    function invariant_totalSupply_is_always_zero() public {
        assertEq(0, weth.totalSupply());
    }
}
// [PASS] invariant_totalSupply_is_always_zero() (runs: 256, calls: 3840, reverts: 2216)
// Test passes but there are plenty of reverts
// Functions of WETH, e.g. withdraw(), transfer() or transferFrom() will revert if the balance of WETH < amount to withdraw or transfer
// that actually has been the case for 2216 times
// runs: number of sequence of functions called from the foundry 