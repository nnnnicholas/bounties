// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


/**
 * @title Leaderboard
 * @author @nnnnicholas
 * @dev Receive ETH and associate contributions with contract addresses.
 */
contract Leaderboard is Ownable, ReentrancyGuard, Pausable{
    mapping(address => uint256) attention;
    uint256 public totalAttention;

    event attentionDrawnTo(address _contract, uint256 amount);
    event attentionReset(address _contract);

    /**
     * @dev Store cumulative value in attention mapping
     * @param _contract to pay attention to
     */
    function payAttention(address _contract) external payable nonReentrant whenNotPaused(){
        attention[_contract] += msg.value;
        totalAttention += msg.value;
        emit attentionDrawnTo(_contract, msg.value);
    }

    /**
     * @dev Retrieve attention paid to a given address
     * @return attention measured in wei
     */
    function retrieveAttention(address _contract) external view returns (uint256) {
        return attention[_contract];
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Contract contains no ETH");
        address owner = owner();
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Failed to send Ether");
    }

    function withdrawTo(address payable _to, uint256 _amount) public onlyOwner nonReentrant {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function resetAttention(address _contract) external onlyOwner nonReentrant{
        attention[_contract] = 0;
        emit attentionReset(_contract);

    }

    function pause() external onlyOwner nonReentrant{
        _pause();
    }

    function unpause() external onlyOwner nonReentrant{
        _unpause();
    }

    receive() external payable nonReentrant {}

    fallback() external payable nonReentrant {}
}