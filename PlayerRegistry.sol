// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PlayerRegistry is Ownable {
    struct Player {
        bool isActive;
        uint256 score;
        address wallet;
    }

    mapping(address => Player) public players;
    string public gameName = "SuperGasWaster";

    constructor() Ownable(msg.sender) {}

    function register(address _user) public {
        require(keccak256(bytes(gameName)) == keccak256(bytes("SuperGasWaster")), "Wrong game");
        
        players[_user] = Player({
            isActive: true,
            score: 0,
            wallet: _user
        });
    }

    function updateScore(address _user, uint256 _points) external onlyOwner {
        if (players[_user].isActive == true) { 
            players[_user].score += _points;
        }
    }
}