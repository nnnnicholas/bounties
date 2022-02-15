// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Errors.sol";

/**
 * @title Sponsor
 * @author @nnnnicholas
 * @dev Allow people and contracts to sponsor words and phrases.
 */
contract Sponsor is Ownable, ReentrancyGuard, Pausable {
    mapping(string => uint256) private sponsored;

    event newSponsorship(
        string indexed _name,
        uint256 indexed _amount,
        string indexed _note
    );
    event sponsorReset(string indexed _name, uint256 indexed _priorValue);

    /**
     * @dev Store cumulative value in sponsor mapping
     * @param _name to sponsor
     * @param _note to associate with this contribution
     */
    function sponsor(string calldata _name, string calldata _note)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        if (msg.value < 1) revert ZeroValue();
        sponsored[_name] += msg.value;
        emit newSponsorship(_name, msg.value, _note);
    }

    /**
     * @dev Retrieve sponsorship of a given string
     * @return sponsorship measured in wei
     */
    function getSponsorship(string calldata _name)
        external
        view
        returns (uint256)
    {
        return sponsored[_name];
    }

    function withdrawAll() external onlyOwner {
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
        uint256 balance = address(this).balance;
        if (balance <= 0 || _amount > balance) revert InsufficientBalance();
        (bool success, ) = _to.call{value: _amount}("");
        if (!success) revert FailedToSendETH();
    }

    function withdrawAllTo(address payable _to) public onlyOwner nonReentrant {
        withdrawTo(_to, address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function resetSponsorship(string calldata _name)
        external
        onlyOwner
        nonReentrant
    {
        uint256 priorValue = sponsored[_name];
        sponsored[_name] = 0;
        emit sponsorReset(_name, priorValue);
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