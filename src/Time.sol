// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;
import "forge-std/console.sol";

contract Auction {
    uint256 public startAt = block.timestamp + 1 days;
    uint256 public endAt = block.timestamp + 4 days;

    function bid() external {
        console.logUint(block.timestamp);
        console.logUint(startAt);
        console.logUint(endAt);
        require(
            block.timestamp >= startAt && block.timestamp < endAt, "cannot bid"
        );
    }

    function end() external {
        require(block.timestamp >= endAt, "cannot end");
    }
}