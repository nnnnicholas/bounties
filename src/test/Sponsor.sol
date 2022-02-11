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

    function setUp() public {}

    function testSponsorWithFuzzing(string calldata x, uint64 y, string calldata z) public {
        // TODO why limited to uint32?
        sponsor.sponsor{value: y}(x, z);
        assert(sponsor.getSponsorship(x) == y);
    }

    function testSponsorManyWithFuzzing(string calldata x, uint16 z, string calldata q) public {
        // TODO why limited to uint32?
        uint256 y = 100000;
        sponsor.sponsor{value: y}(x, q);
        assert(sponsor.getSponsorship(x) == y);
        sponsor.sponsor{value: z}(x, q);
        uint256 a = uint256(y) + uint256(z);
        assert(sponsor.getSponsorship(x) == a);
        
    }

    function testFailZeroValue() public {
        sponsor.sponsor{value: 0}("test", "comment");
        vm.expectRevert(bytes4(keccak256(bytes("ZeroValue()"))));
    }
}
