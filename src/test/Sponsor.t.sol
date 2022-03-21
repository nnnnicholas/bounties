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

    function expectEmit(
        bool,
        bool,
        bool,
        bool
    ) external;
}

contract NotPayable {
    fallback() external {}
}

contract SponsorTest is DSTest {
    // events imported from Sponsor.sol
    event NewSponsorship(
        address _from,
        string indexed _name,
        uint256 indexed _amount,
        string indexed _note
    );
    event SponsorReset(string indexed _name, uint256 indexed _priorValue);
    event Withdrawal(address indexed _withdrawnBy, uint256 indexed _amount);

    // Setup
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

    // Sponsor tests
    function testCannotSponsorZeroValue() public {
        vm.expectRevert(Sponsor.ZeroValue.selector);
        sponsor.sponsor{value: 0}("test", "comment");
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

    function testResetAndSponsorAgain() public {
        testResetSponsorship();
        testSponsorMany();
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

    function testWithdrawAllTo() public {
        vm.startPrank(addr2);
        testSponsor(); // "Sponsored Name" sponsored for 10 wei
        assertEq(addr3.balance, 0);
        vm.stopPrank();
        sponsor.withdrawAllTo(addr3);
        assertEq(addr3.balance, 10);
        assertEq(sponsor.getBalance(), 0);
    }

    function testCannotWithdrawAllZeroBalance() public {
        vm.expectRevert(Sponsor.ZeroBalance.selector);
        sponsor.withdrawAll();
    }

    function testCannotWithdrawMoreThanBalance() public {
        testSponsor();
        vm.expectRevert(Sponsor.InsufficientBalance.selector);
        sponsor.withdrawTo(addr1, 11);
    }

    function testCannotWithdrawToNotPayable() public {
        testSponsor();
        vm.expectRevert(Sponsor.FailedToSendETH.selector);
        sponsor.withdrawTo(payable(address(notPayable)), 1);
    }

    function testCannotWithdrawToZeroBalance() public {
        vm.expectRevert(Sponsor.ZeroBalance.selector);
        sponsor.withdrawTo(addr1, 1);
    }

    function testSponsorWithFuzzing(uint256 x) public {
        vm.assume(x != 0);
        vm.deal(addr2, x);
        string memory name = "Sponsored name";
        string memory note = "Note text";
        vm.startPrank(addr2);
        sponsor.sponsor{value: x}(name, note);
        assertEq(sponsor.getSponsorship(name), x);
        vm.stopPrank();
    }

    // Withdraw tests with Fuzzing
    function testWithdrawToWithFuzzing(uint256 x, uint256 y) public {
        vm.assume(y <= x && y != 0);
        testSponsorWithFuzzing(x); // Sponsor
        // Withdraw
        assertEq(addr3.balance, 0);
        sponsor.withdrawTo(addr3, y);
        assertEq(addr3.balance, y);
        assertEq(sponsor.getBalance(), x - y);
    }

    function testWithdrawAllWithFuzzing(uint256 x, uint256 y) public {
        vm.assume(y <= x && y != 0);
        testSponsorWithFuzzing(x); // Sponsor
        // Withdraw
        assertEq(addr3.balance, 0);
        sponsor.withdrawTo(addr3, y);
        assertEq(addr3.balance, y);
        assertEq(sponsor.getBalance(), x - y);
    }

    // Events tests
    function testEventNewSponsorship() public {
        vm.expectEmit(true, true, true, true);
        emit NewSponsorship(address(this), "Sponsored name", 10, "Note text");
        testSponsor();
    }

    function testEventSponsorReset() public {
        testSponsorMany();
        vm.expectEmit(true, true, false, false);
        emit SponsorReset("Sponsored name", 30);
        sponsor.resetSponsorship("Sponsored name");
    }

    function testEventSponsorWithdraw() public {
        testSponsor();
        vm.expectEmit(true, true, false, false);
        emit Withdrawal(address(this), 10);
        sponsor.withdrawAll();
    }

    receive() external payable {
        emit testReceivedEth(msg.sender);
    }

    fallback() external payable {}
}
