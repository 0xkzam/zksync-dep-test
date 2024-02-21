// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EchoContractA {
    address public owner;

    constructor() {
        owner = msg.sender; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this operation");
        _;
    }

    receive() external payable {
        (bool sent, ) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send ETH back");
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance in contract");
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Failed to send ETH");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
