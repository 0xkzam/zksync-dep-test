// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract StorageContract {
    mapping(address => uint256) public ethBalances;    
    // token address => (owner address => balance)
    mapping(address => mapping(address => uint256)) public erc20Balances;

    receive() external payable {
        ethBalances[msg.sender] += msg.value;
    }

    function depositERC20(address tokenAddress, uint256 amount) external {
        IERC20 token = IERC20(tokenAddress);
        bool sent = token.transferFrom(msg.sender, address(this), amount);
        require(sent, "Token transfer failed");
        erc20Balances[tokenAddress][msg.sender] += amount;
    }

    function withdrawETH(uint256 amount) external {
        require(ethBalances[msg.sender] >= amount, "Insufficient balance");
        ethBalances[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send ETH");
    }

    function withdrawERC20(address tokenAddress, uint256 amount) external {
        require(erc20Balances[tokenAddress][msg.sender] >= amount, "Insufficient token balance");
        erc20Balances[tokenAddress][msg.sender] -= amount;
        IERC20 token = IERC20(tokenAddress);
        bool sent = token.transfer(msg.sender, amount);
        require(sent, "Token transfer failed");
    }
}
