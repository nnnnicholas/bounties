//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "ds-test/test.sol";

interface Vm {
    function label(address, string calldata) external;
}

contract JustChecking is DSTest {
    Vm vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        // vm.label(address(0), "Black Hole");
    }

    function testDeployer() public {
        emit log_named_address("msg.sender", msg.sender);
        emit log_named_address("tx.origin", tx.origin);
        emit log_named_address("this", address(this));
    }

    function testLabel() public {
        // emit log_address(address(0)); // Black Hole
    }
}
