// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "../Bounties.sol";

interface Vm {
}

contract BountiesTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    Bounties bounty = new Bounties();

    function setUp() public {
    }

    function testPayAttention(string memory x) public {
        bounty.payAttention{value: 8 ether}(x);
        assert(bounty.getAttention(x) == 8 ether);
    }

    function testFailExample() public {
        assertTrue(false);
    }
}
