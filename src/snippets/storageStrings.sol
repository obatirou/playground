// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import "forge-std/Test.sol";

// Retriving string in storage
// Ressources:
// https://noxx.substack.com/p/evm-deep-dives-the-path-to-shadowy-3ea
// https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html#bytes-and-string
// https://docs.soliditylang.org/en/v0.8.16/abi-spec.html#basic-design

contract ContractDummy {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract TestContractDummy is Test {
    ContractDummy contractDummy;

    function testSetNameLessThan32() public {
        contractDummy = new ContractDummy("slot1");
        // assertEq(vm.load(address(contractDummy), bytes32(0)), "slot1"); will fail
        // If the string is less than 31 bytes (our case)
        // it will store the bytes left aligned and the length * 2 (here 5 * 2 = 10 or 0xa) right aligned
        assertEq(
            bytes32(abi.encodePacked("slot1")),
            0x736c6f7431000000000000000000000000000000000000000000000000000000
        );
        assertEq(
            vm.load(address(contractDummy), bytes32(0)),
            0x736c6f743100000000000000000000000000000000000000000000000000000a
        );
    }

    function testSetNameMoreThan32() public {
        contractDummy = new ContractDummy(
            "More than 32 charaters hence will not fit in one slot"
        ); // 53 charaters
        // When more than 32 bytes it will store in main slot (here 0) length * 2 + 1 hence 107 or 0x6b
        assertEq(
            vm.load(address(contractDummy), bytes32(0)),
            0x000000000000000000000000000000000000000000000000000000000000006b
        );
        // encodePacked "More than 32 charaters hence will not fit in one slot"
        bytes
            memory phrase = hex"4d6f7265207468616e203332206368617261746572732068656e63652077696c6c206e6f742066697420696e206f6e6520736c6f74";
        bytes memory test = abi.encodePacked(
            "More than 32 charaters hence will not fit in one slot"
        );
        assertEq(keccak256(test), keccak256(phrase));
        // Data will be stored over 2 slots at keccak256(0) and keccak256(0) + 1
        assertEq(
            vm.load(
                address(contractDummy),
                keccak256(abi.encodePacked(uint256(0)))
            ),
            0x4d6f7265207468616e203332206368617261746572732068656e63652077696c
        );
        assertEq(
            vm.load(
                address(contractDummy),
                bytes32(
                    uint256(keccak256(abi.encodePacked(uint256(0)))) +
                        uint256(1)
                )
            ),
            0x6c206e6f742066697420696e206f6e6520736c6f740000000000000000000000
        );
    }
}
