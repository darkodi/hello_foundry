// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import {Auction} from "../src/Time.sol";

contract TimeTest is Test {
    Auction public auction;
    uint256 private startAt;

    // vm.warp - set block.timestamp to future timestamp
    // vm.roll - set block.number
    // skip - increment current timestamp
    // rewind - decrement current timestamp

    function setUp() public {
        auction = new Auction();
        startAt = block.timestamp;
    }

    function testBidFailsBeforeStartTime() public {
        vm.expectRevert(bytes("cannot bid")); 
        auction.bid(); // will revert because block.timestamp < startAt
    }
     function testBid() public {
        vm.warp(startAt + 3 days); // set block.timestamp in the future (block.timestamp > startAt && block.timestamp < endAt)
        auction.bid();
    }
     function testBidFailsAfterEndTime() public {
        vm.expectRevert(bytes("cannot bid"));
        vm.warp(startAt + 4 days); // cannot bid after endAt time
        auction.bid();
    }
      function testTimestamp() public {
        uint256 t = block.timestamp;
        // skip 100sec from t
        skip(100);
        assertEq(block.timestamp, t + 100);

        // decrease 10sec from current timestamp;
        rewind(10);
        assertEq(block.timestamp, t+90);
    }
    
}