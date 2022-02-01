// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "../Bounties.sol";

contract BountiesTest is DSTest {
    Bounties bounty;
    function setUp() public {
        bounty = new Bounties();
    }

    function testExample() public {
        assertTrue(true);
    }

    function testFailExample() public {
        assertTrue(false);
    }
}
