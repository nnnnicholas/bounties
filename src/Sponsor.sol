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

    event NewSponsorship(
        address _from,
        string indexed _name,
        uint256 indexed _amount,
        string indexed _note
    );
    event SponsorReset(string indexed _name, uint256 indexed _priorValue);
    event Withdrawal(address indexed _withdrawnBy, uint256 indexed _amount);

    // Errors
    error ZeroValue();
    error ZeroBalance();
    error FailedToSendETH();
    error InsufficientBalance();

    /**
     * @dev Store cumulative value in sponsor mapping
     * @param _name String to sponsor
     * @param _note String to associate with this contribution
     */
    function sponsor(string calldata _name, string calldata _note)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        if (msg.value < 1) revert ZeroValue();
        sponsored[_name] += msg.value;
        emit NewSponsorship(msg.sender, _name, msg.value, _note);
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

    /**
     * @dev Withdraw total contract balance to msg.sender
     */
    function withdrawAll() external onlyOwner nonReentrant {
        _withdrawTo(payable(msg.sender), address(this).balance);
    }

    /**
     * @dev Withdraw a given amount to a given address
     * @param _to Address to send funds to
     * @param _amount Amount to withdraw
     */
    function withdrawTo(address payable _to, uint256 _amount)
        public
        onlyOwner
        nonReentrant
    {
        _withdrawTo(_to, _amount);
    }

    function withdrawAllTo(address payable _to) public onlyOwner nonReentrant {
        _withdrawTo(_to, address(this).balance);
    }

    function _withdrawTo(address payable _to, uint256 _amount) private {
        uint256 balance = address(this).balance;
        if (balance == 0) revert ZeroBalance();
        if (_amount > balance) revert InsufficientBalance();
        (bool success, ) = _to.call{value: _amount}("");
        if (!success) revert FailedToSendETH();
        emit Withdrawal(_to, _amount);
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
        emit SponsorReset(_name, priorValue);
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