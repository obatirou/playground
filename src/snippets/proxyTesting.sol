// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {TransparentUpgradeableProxy} from "@openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";

import "forge-std/Test.sol";

// Basic proxy with a dummy implementation
// A lot of shortcuts were taken only to show how to test the proxy initialization
// and packed variables
contract Implementation {
    bool public initialized;
    address public externalContract;

    constructor(address _externalContract) {
        externalContract = _externalContract;
    }

    // dummy function
    function callExternalContract(bytes calldata input) external returns (bool succes, bytes memory data) {
        (succes, data) = externalContract.call(input);
    }

    // Should be restricted to only owner/admin/initializer
    // also should check that it is not already initialized
    // for the sake of simplicity we skip it
    function initialize(address _externalContract) external {
        initialized = true;
        externalContract = _externalContract;
    }
}

contract TestProxyInitialization is Test {
    // should be a real contract
    address externalContract = address(uint160(111111));
    address proxy;

    function setUp() public {
        address admin = address(uint160(123));
        Implementation implementation = new Implementation(externalContract);
        proxy = address(new TransparentUpgradeableProxy(address(implementation), admin, bytes("")));
    }

    function testInitialization() public {
        // Example of initialization testing of a proxy with forge
        // We need to ensure slots do not move and variables are actually packed
        // Let's suppose Implementation storage has 2 variables: initialized (bool) and externalContract (address)
        // Those variables should be packed together in one slot

        // First ensure proxy storage is empty before initialization
        assertEq(vm.load(proxy, bytes32(uint256(0))), bytes32(0));
        assertEq(vm.load(proxy, bytes32(uint256(1))), bytes32(0));

        // Initialize proxy by casting the proxy address to its implementation
        Implementation(proxy).initialize(externalContract);

        // Retrieve the first slot value of the proxy
        bytes32 packedVars = vm.load(proxy, bytes32(uint256(0)));
        // packedVars should be something like 0x00000000000000000000000beeb15cf4f3471903a4e987f1fb8057f3ea7e5301
        // Bool takes 1 byte and should be set to true after initialiaztion, address takes 20 bytes
        // We ensure address is 8 bits shifted to the left and packedVars included the bool which is represented by a uint8(1) right padded.
        assertEq(packedVars, bytes32(uint256(uint160(externalContract)) << 8 | uint256(1)));
        // assert public methods send back the values we expect
        assertEq(Implementation(proxy).initialized(), true);
        assertEq(Implementation(proxy).externalContract(), externalContract);

        // Ensure following slot is still empty
        assertEq(vm.load(proxy, bytes32(uint256(1))), bytes32(0));

        // To NOTE:
        // we need to take into accounut that even if we check for empty slot it does not mean it is error prone. Having a mapping in storage would introduce an empty slot. Hence further tests and verification are needed.
        // https://docs.soliditylang.org/en/v0.8.13/internals/layout_in_storage.html#mappings-and-dynamic-arrays

        // You have a better way ? PLease share it !
    }
}
