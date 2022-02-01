// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Errors.sol";

/**
 * @title Bounties
 * @author @nnnnicholas
 * @dev Receive ETH and associate contributions with strings.
 */
contract Bounties is Ownable, ReentrancyGuard, Pausable {
    mapping(string => uint256) private attention;
    uint256 public totalAttention;

    event attentionDrawnTo(string _subject, uint256 amount);
    event attentionReset(string _subject);

    /**
     * @dev Store cumulative value in attention mapping
     * @param _subject to pay attention to
     */
    function payAttention(string calldata _subject)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        attention[_subject] += msg.value;
        totalAttention += msg.value;
        emit attentionDrawnTo(_subject, msg.value);
    }

    /**
     * @dev Retrieve attention paid to a given string
     * @return attention measured in wei
     */
    function getAttention(string calldata _subject)
        external
        view
        returns (uint256)
    {
        return attention[_subject];
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance <= 0) revert ZeroBalance();
        address owner = owner();
        (bool success, ) = owner.call{value: balance}("");
        if (!success) revert FailedToSendETH();
    }

    function withdrawTo(address payable _to, uint256 _amount)
        public
        onlyOwner
        nonReentrant
    {
        (bool success, ) = _to.call{value: _amount}("");
        if (!success) revert FailedToSendETH();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function resetAttention(string calldata _subject) external onlyOwner nonReentrant {
        attention[_subject] = 0;
        emit attentionReset(_subject);
    }

    function pause() external onlyOwner nonReentrant {
        _pause();
    }

    function unpause() external onlyOwner nonReentrant {
        _unpause();
    }

    receive() external payable nonReentrant {}

    fallback() external payable nonReentrant {}
}
