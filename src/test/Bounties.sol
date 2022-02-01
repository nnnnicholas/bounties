// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";
import "../Bounties.sol";


interface Vm {
    function expectRevert(bytes4) external;
}

contract BountiesTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    Bounties bounty = new Bounties();

    function setUp() public {}

    function testPayAttentionWithFuzzing(string memory x, uint64 y) public {
        // TODO why limited to uint32?
        bounty.payAttention{value: y}(x);
        assert(bounty.getAttention(x) == y);
    }

    function testPayAttentionManyWithFuzzing(string memory x, uint16 z) public {
        // TODO why limited to uint32?
        uint256 y = 100000;
        bounty.payAttention{value: y}(x);
        assert(bounty.getAttention(x) == y);
        bounty.payAttention{value: z}(x);
        uint256 a = uint256(y) + uint256(z);
        assert(bounty.getAttention(x) == a);
        
    }

    function testFailZeroValue() public {
        bounty.payAttention{value: 0}("test");
        vm.expectRevert(bytes4(keccak256(bytes("ZeroValue()"))));
    }
}
