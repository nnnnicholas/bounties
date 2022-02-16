// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "../Sponsor.sol";

interface Vm {
    function expectRevert(bytes4) external;
}

contract SponsorTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    Sponsor sponsor = new Sponsor();

    function setUp() public {
        emit log_address(address(sponsor));
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

    function testWidrawAll() public {
        testSponsor();
        assertEq(sponsor.getSponsorship("Sponsored name"), 10);
        assertEq(sponsor.getBalance(), 10);
        sponsor.withdrawAll();
        assertEq(sponsor.getSponsorship("Sponsored name"), 0);
    }

    // Withdraw tests with Fuzzing

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
}
