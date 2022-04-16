// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract AirDrop is ERC20("AirDrop", "AD") {
    bytes32 public immutable root; // should be always imutable
    uint256 public immutable rewardAmount;

    // we keep track of person that already claim they tokens
    mapping(address =>  bool) claimed;

    // 1 - step from merkel tree has - root
    constructor(bytes32 _root, uint256 _rewardAmount) {
        root = _root;
        rewardAmount = _rewardAmount;
    }
    
    // 2 - claim airdrop and check the merkelproof
    function claim(bytes32[] calldata _proof) external {
        require(!claimed[msg.sender], "Already claimed air drop");
        // we set the claimed to true / prevent call again claimed tokens
        claimed[msg.sender] = true;

        // to create the leaf we take person address and we hash it 
        bytes32 _leaf = keccak256(abi.encodePacked(msg.sender));

        // we require that the person is eligible - we check with merkel proof
        require(MerkleProof.verify(_proof, root, _leaf), "Incorrect merkle proof");

        // if exist we mint tokens for them
        _mint(msg.sender, rewardAmount);
    }

}
