// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

//import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {
        // contract initialization
    }
}
