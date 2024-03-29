// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.16;

import {Test} from "forge-std/Test.sol";
import {EmptyContractWithConstructor} from "./EmptyContractWithConstructor.sol";

import "forge-std/console.sol";

// forge test --use solc:0.8.16
// launch test with solc 0.8.16
contract TestEmptyContractWithContructor is Test {
    bytes runtimeBytecode;

    function setUp() public {
        runtimeBytecode = type(EmptyContractWithConstructor).runtimeCode;
    }

    function testAgainstSolc() public {
        // Assert local solc used is in 0.8.16
        // if grep returned 0, it matched so check that it matched 0.8.16
        string memory bashCommand = "./src/scripts/solc-version-grep.sh";

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        uint256 matched = abi.decode(vm.ffi(inputs), (uint256));

        assertEq(matched, uint256(0));

        // We explicitly optmize and use 200 runs to match the foundry toml
        bashCommand =
            './src/scripts/solc-compile-EmptyContractWithConstructor.sh';

        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        bytes memory res = abi.decode(vm.ffi(inputs), (bytes));
        // assert the 2 bytecodes have 63 characters
        assertEq(res.length, uint256(0x3F));
        assertEq(runtimeBytecode.length, uint256(0x3F));

        // if you want to compare by hand use -vvvv
        // it should print the following bytecodes
        // 0x6080604052600080fdfea26469706673582212200224441d5924782d78e91699ff5aebef529ec347bdcd5e88f49a05c1faf4410d64736f6c63430008100033
        console.logBytes(res);
        // 0x6080604052600080fdfea26469706673582212208ddea11913865947de64d6e2a7c6171f91add3cf6e1f97a0ebd576d329d2823764736f6c63430008100033
        console.logBytes(runtimeBytecode);

        // The contract do nothing and the beginning looks the same
        // 60 PUSH1
        // 80
        // 60 PUSH1
        // 40
        // 52 MSTORE
        // 60 PUSH1
        // 00
        // 80 DUP1
        // fd REVERT
        // fe INVALID
        // ... (more opcodes that are weird)
        // those extraneous opcodes are differents when compiling with solc
        // or when using type(EmptyContractWithContructor).runtimeCode
        // 1. Why are there extraneous opcodes ?
        // The runtime bytecode should stop at the revert or at least at invalid opcodes
        // 2. Why are the 2 bytecodes different ?
        // They should be identical
        // if anyone has an idea or even better the explanation, please share !
        assertFalse(
            keccak256(res) == keccak256(runtimeBytecode),
            "solc and type(EmptyContractWithContructor).runtimeCode are equal"
        );
    }
}
