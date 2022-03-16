// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "../Sponsor.sol";

interface Vm {
    function expectRevert(bytes4) external;

    function prank(address) external;

    function startPrank(address) external;

    function stopPrank() external;

    function deal(address, uint256) external;

    function label(address, string calldata) external;

    function assume(bool) external;
}

contract NotPayable {
    fallback() external{}
}

contract SponsorTest is DSTest {
    event testReceivedEth(address sender); // emits when `receive()` is called
    Vm vm = Vm(HEVM_ADDRESS);
    address payable deployer = payable(this);
    address payable addr1 = payable(0x00a329c0648769A73afAc7F9381E08FB43dBEA72); // Default Forge test address
    address payable addr2 = payable(0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa); // A supplementary address
    address payable addr3 = payable(0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB); // A supplementary address
    NotPayable notPayable = new NotPayable(); // A contract that cannot be paid
    Sponsor sponsor = new Sponsor();

    function setUp() public {
        vm.label(address(this), "deployer");
        vm.label(addr1, "addr1");
        vm.label(addr2, "addr2");
        vm.deal(address(addr2), uint256(1 ether)); // give test address 1 ether
    }

    function testLogBalances() public {
        emit log_address(address(this));
        emit log_named_uint("test balance", address(this).balance);
        emit log_address(address(addr1));
        emit log_named_uint("addr1 balance", addr1.balance);
        emit log_address(address(addr2));
        emit log_named_uint("addr2 balance", addr2.balance);
    }

    // Sponsor tests: Regular
    function testFailZeroValue() public {
        sponsor.sponsor{value: 0}("test", "comment");
        vm.expectRevert(bytes4(keccak256(bytes("ZeroValue()"))));
    }

    function testSponsor() public {
        string memory name = "Sponsored name";
        string memory note = "Note text";
        sponsor.sponsor{value: 10}(name, note);
        assertEq(sponsor.getSponsorship(name), 10);
    }

    function testSponsorMany() public {
        string memory name = "Sponsored name";
        string memory note = "Note text";
        sponsor.sponsor{value: 10}(name, note);
        assertEq(sponsor.getSponsorship(name), 10);
        vm.prank(addr2);
        sponsor.sponsor{value: 20}(name, note);
        assertEq(sponsor.getSponsorship(name), 30);
    }

    function testResetSponsorship() public {
        testSponsorMany();
        sponsor.resetSponsorship("Sponsored name");
        assertEq(sponsor.getSponsorship("Sponsored name"), 0);
    }

    function testSponsorDifferentNamesAndNotes() public {
        string memory name1 = "Sponsored name 1";
        string memory name2 = "Sponsored name 2";
        string memory note1 = "Note text 1";
        string memory note2 = "Note text 2";
        sponsor.sponsor{value: 10}(name1, note1);
        assertEq(sponsor.getSponsorship(name1), 10);
        sponsor.sponsor{value: 20}(name2, note2);
        assertEq(sponsor.getSponsorship(name2), 20);
        sponsor.sponsor{value: 10}(name1, note1);
        assertEq(sponsor.getSponsorship(name1), 20);
        sponsor.sponsor{value: 20}(name2, note2);
        assertEq(sponsor.getSponsorship(name2), 40);
    }

    function testResetSponsorshipMany() public {
        testSponsorDifferentNamesAndNotes();
        assertEq(sponsor.getSponsorship("Sponsored name 1"), 20);
        sponsor.resetSponsorship("Sponsored name 1");
        assertEq(sponsor.getSponsorship("Sponsored name 1"), 0);
        assertEq(sponsor.getSponsorship("Sponsored name 2"), 40);
        sponsor.resetSponsorship("Sponsored name 2");
        assertEq(sponsor.getSponsorship("Sponsored name 2"), 0);
    }

    // Withdraw tests

    function testWithdrawAll() public {
        vm.prank(addr2);
        testSponsor(); // "Sponsored Name" sponsored for 10 wei
        uint256 balanceBefore = address(this).balance;
        sponsor.withdrawAll();
        assertEq(sponsor.getBalance(), 0);
        assertEq(deployer.balance, (balanceBefore + 10));
    }

    function testWithdrawTo() public {
        vm.startPrank(addr2);
        testSponsor(); // "Sponsored Name" sponsored for 10 wei
        assertEq(addr3.balance, 0);
        vm.stopPrank();
        sponsor.withdrawTo(addr3, 5); // tktk fuzz this
        assertEq(addr3.balance, 5);
        assertEq(sponsor.getBalance(), 5);
    }

    function testFailWithdrawAllZeroBalance() public {
        sponsor.withdrawAll();
        vm.expectRevert(bytes4(keccak256(bytes("ZeroBalance()"))));
    }

    function testFailWithdrawToNotPayable() public {
        testSponsor();
        vm.expectRevert(Sponsor.FailedToSendETH.selector);
        sponsor.withdrawTo(payable(address(notPayable)), 1);
    }

    function testFailWithdrawToZeroBalance() public {
        vm.expectRevert(bytes4(keccak256(bytes("ZeroBalance()"))));
        sponsor.withdrawTo(addr1, 1);
    }

    // function testWithdrawAllTo

    //    function withdrawTo(address payable _to, uint256 _amount)
    //     public
    //     onlyOwner
    //     nonReentrant
    // {
    //     uint256 balance = address(this).balance;
    //     if (balance == 0 || _amount > balance) revert InsufficientBalance();
    //     (bool success, ) = _to.call{value: _amount}("");
    //     if (!success) revert FailedToSendETH();
    //     emit withdrawl(_to, _amount);
    // }

    // Withdraw tests with Fuzzing
    function testWithdrawToWithFuzzing(uint8 x) public {
        vm.assume(x <= 10);
        vm.startPrank(addr2);
        testSponsor(); // "Sponsored Name" sponsored for 10 wei
        assertEq(addr3.balance, 0);
        vm.stopPrank();
        sponsor.withdrawTo(addr3, x);
        assertEq(addr3.balance, x);
        assertEq(sponsor.getBalance(), 10 - x);
    }

    // Sponsor tests with Fuzzing
    function testSponsorWithFuzzing(
        string calldata x,
        uint64 y,
        string calldata z
    ) public {
        // TODO why limited to uint32?
        sponsor.sponsor{value: y}(x, z);
        assertEq(sponsor.getSponsorship(x), y);
    }

    function testSponsorManyWithFuzzing(
        string calldata x,
        uint16 z,
        string calldata q
    ) public {
        // TODO why limited to uint32?
        uint256 y = 100000;
        sponsor.sponsor{value: y}(x, q);
        assertEq(sponsor.getSponsorship(x), y);
        sponsor.sponsor{value: z}(x, q);
        uint256 a = uint256(y) + uint256(z);
        assertEq(sponsor.getSponsorship(x), a);
    }

    receive() external payable {
        emit testReceivedEth(msg.sender);
    }

    fallback() external payable {}
}
