// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

error Unauthorized();

contract OwnerUpOnly {
    address public immutable owner;
    uint256 public count;

    constructor() {
        owner = msg.sender;
    }

    function increment() external {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        count++;
    }
}

contract OwnerUpOnlyTest is Test {
    OwnerUpOnly upOnly;

    function setUp() public {
        upOnly = new OwnerUpOnly();
    }

    function test_IncrementAsOwner() public {
        assertEq(upOnly.count(), 0);
        upOnly.increment();
        assertEq(upOnly.count(), 1);
    }
    //  using testFail is considered an anti-pattern since it does not tell us anything about why upOnly.increment() reverted.
    function testFail_IncrementAsNotOwner() public {
        vm.prank(address(0)); // prank cheatcode changed our identity to the zero address for the next call (upOnly.increment())
        upOnly.increment();
    }

    // Notice that we replaced `testFail` with `test`
    // use expectRevert - good practice
    function test_RevertWhen_CallerIsNotOwner() public {
        vm.expectRevert(Unauthorized.selector); // explicit reason of failing: Unauthorized
        vm.prank(address(0));
        upOnly.increment();
    }
}
