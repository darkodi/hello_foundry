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

    constructor(Fallback _fback) {
        fback = _fback;
    }

    function sendToFallback(uint256 amount) public {
        //amount = bound(amount, 0, 0.001 ether);

        // direct transfer of amount to Fallback contract
        (bool ok,) = address(fback).call{value: amount}(""); 
        require(ok, "sendToFallback failed");
    }

    function contribute() public {

        fback.contribute();
    }


}
contract FallbackTest is Test {
   
    address attacker;
    Fallback fback;
    Handler public handler;
    function setUp() public {
        // Deploy the Fallback contract
        fback = new Fallback();
        handler = new Handler(fback);
        // Initialize the attacker address (could be any address)
        attacker = address(0x1234);

        vm.deal(attacker, 1 ether); // Fund attacker with 1 ether
        vm.deal(address(fback), 10 ether); // Fund fback with 10 ether

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = Handler.contribute.selector;
        selectors[1] = Handler.sendToFallback.selector;


        targetContract(address(handler));
        // this is used to target specific functions for the random execution by the Foundry
        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectors})
        );
        targetSender(attacker);
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