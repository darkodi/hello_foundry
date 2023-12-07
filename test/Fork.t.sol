// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

// Wrapped ETH (WETH) - is ERC20 compatible, unlike ETH
// IWETH - interface to interact with WETH contract
interface IWETH {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}

// forge test --fork-url YOUR_NODE_URL --match-path test/Fork.t.sol -vvv

contract ForkTest is Test {
    IWETH public weth;

    function setUp() public {
        weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // This is the address of the WETH contract on the Ethereum mainnet
    }

    function testDeposit() public {
        uint256 balBefore = weth.balanceOf(address(this));
        console.log("balance before", balBefore);

        weth.deposit{value: 50}(); // converts 50 wei of ETH to 50 wei of WETH 

        uint256 balAfter = weth.balanceOf(address(this));
        console.log("balance after", balAfter);
    }
}