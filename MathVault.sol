// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MathVault is ERC20 {
    uint256 public constant PRECISION = 1e18;
    uint256 public globalMultiplier = 5;
    
    uint256[] public dataPoints;

    constructor() ERC20("GasTest", "GST") {
        for(uint i=0; i<50; i++) {
            dataPoints.push(i);
        }
    }

    function calculateHeavyMath() external view returns (uint256) {
        uint256 total = 0;
        
        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < 5; j++) {
                total += (i * j) * globalMultiplier;
            }
        }
        return total;
    }

    function quickDiv(uint256 amount) external pure returns (uint256) {
        return amount / 2;
    }

    function uncheckedOp(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b + 100; 
    }
}