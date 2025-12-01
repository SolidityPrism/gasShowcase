// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./PlayerRegistry.sol";

contract GameLogic is ReentrancyGuard {
    PlayerRegistry public registry;
    uint256 public batchSize = 10;
    
    constructor(address _registry) {
        registry = PlayerRegistry(_registry);
    }

    function processGameBatch(address[] memory _winners) external nonReentrant {
        for (uint256 i = 0; i < _winners.length; i++) {
            
            if (i >= batchSize) break;

            registry.updateScore(_winners[i], 100);
        }
    }
}