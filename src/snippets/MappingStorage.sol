// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.15;

import "forge-std/Test.sol";

// Accessing mapping value in storage
// Ressources:
// https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html
// https://book.getfoundry.sh/cheatcodes/load#load

// Value corresponding to a mapping key k is located at keccak256(h(k) . p)
// let's see how to access it with foundry
contract MappingStorageAccess {
    // Storage layout
    // slot 0: stringMapping
    // slot 1: bytesMapping
    // slot 2: uint256Mapping
    // slot 3: uint256 dummy variable

    // The 3 first slots correspinding to mappings are empty
    // The dummy one is not

    // mapping with a string as key
    mapping(string => uint256) public stringMapping;

    // mapping with bytes as key (should be same behavior than string)
    mapping(bytes => uint256) public bytesMapping;

    // mapping with value type as key (here uint256)
    mapping(uint256 => uint256) public uint256Mapping;

    uint256 public dummyOne = uint256(0xfffffffffffff);

    constructor() {
        stringMapping["a key"] = 0x1;
        stringMapping["a second key more than 32 bytes, normally that should be enough characters"] = 0x2;

        bytesMapping[bytes("a byte key")] = 0x3;
        bytesMapping[bytes("a second key more than 32 bytes, normally that should be enough characters")] = 0x4;

        uint256Mapping[uint256(0xf)] = 0x5;
        uint256Mapping[uint256(0xff)] = 0x6;
    }
}

contract TestMappingStorageAccess is Test {
    address mappingStorageAccess;

    uint256 constant STRINGMAPPING_SLOT = uint256(0);
    uint256 constant BYTESMAPPING_SLOT = uint256(1);
    uint256 constant UINT256MAPPING_SLOT = uint256(2);
    uint256 constant DUMMYONE_SLOT = uint256(3);

    function setUp() public {
        mappingStorageAccess = address(new MappingStorageAccess());
    }

    function testAccessMappingsValue() public {
        /* ------------- Let's confirm that the 3 first slots are empty ------------- */
        bytes32 dataFirstSlot = vm.load(mappingStorageAccess, bytes32(STRINGMAPPING_SLOT));
        assertEq(uint256(dataFirstSlot), uint256(0));

        bytes32 dataSecondSlot = vm.load(mappingStorageAccess, bytes32(BYTESMAPPING_SLOT));
        assertEq(uint256(dataSecondSlot), uint256(0));

        bytes32 dataThirdSlot = vm.load(mappingStorageAccess, bytes32(UINT256MAPPING_SLOT));
        assertEq(uint256(dataThirdSlot), uint256(0));

        bytes32 dataFourthSlot = vm.load(mappingStorageAccess, bytes32(DUMMYONE_SLOT));
        assertEq(uint256(dataFourthSlot), uint256(0xfffffffffffff));

        /* -------------------------------------------------------------------------- */
        /*                                 key string                                 */
        /* -------------------------------------------------------------------------- */
        string memory keyString = "a key";
        uint256 value = MappingStorageAccess(mappingStorageAccess).stringMapping(keyString);
        assertEq(value, 0x1);
        // load value from slot
        // vm.load return a 32 bytes that needs to be casted to the mapping value type, here uint256
        bytes32 data = vm.load(mappingStorageAccess, keccak256(bytes(abi.encodePacked(keyString, STRINGMAPPING_SLOT))));
        uint256 result = uint256(data);
        assertEq(result, 0x1);

        keyString = "a second key more than 32 bytes, normally that should be enough characters";
        value = MappingStorageAccess(mappingStorageAccess).stringMapping(keyString);
        assertEq(value, 0x2);
        // load value from slot
        // vm.load return a 32 bytes that needs to be casted to the mapping value type, here uint256
        data = vm.load(mappingStorageAccess, keccak256(bytes(abi.encodePacked(keyString, STRINGMAPPING_SLOT))));
        result = uint256(data);
        assertEq(result, 0x2);

        /* -------------------------------------------------------------------------- */
        /*                                  key bytes                                 */
        /* -------------------------------------------------------------------------- */
        bytes memory bytesKey = bytes("a byte key");
        value = MappingStorageAccess(mappingStorageAccess).bytesMapping(bytesKey);
        assertEq(value, 0x3);
        // load value from slot
        // vm.load return a 32 bytes that needs to be casted to the mapping value type, here uint256
        data = vm.load(mappingStorageAccess, keccak256(bytes(abi.encodePacked(bytesKey, BYTESMAPPING_SLOT))));
        result = uint256(data);
        assertEq(result, 0x3);

        bytesKey = "a second key more than 32 bytes, normally that should be enough characters";
        value = MappingStorageAccess(mappingStorageAccess).bytesMapping(bytesKey);
        assertEq(value, 0x4);
        // load value from slot
        // vm.load return a 32 bytes that needs to be casted to the mapping value type, here uint256
        data = vm.load(mappingStorageAccess, keccak256(bytes(abi.encodePacked(bytesKey, BYTESMAPPING_SLOT))));
        result = uint256(data);
        assertEq(result, 0x4);

        /* -------------------------------------------------------------------------- */
        /*                                 key uint256                                */
        /* -------------------------------------------------------------------------- */
        uint256 uint256Key = uint256(0xf);
        value = MappingStorageAccess(mappingStorageAccess).uint256Mapping(uint256Key);
        assertEq(value, 0x5);
        // load value from slot
        // vm.load return a 32 bytes that needs to be casted to the mapping value type, here uint256
        data = vm.load(mappingStorageAccess, keccak256(bytes(abi.encodePacked(uint256Key, UINT256MAPPING_SLOT))));
        result = uint256(data);
        assertEq(result, 0x5);

        uint256Key = uint256(0xff);
        value = MappingStorageAccess(mappingStorageAccess).uint256Mapping(uint256Key);
        assertEq(value, 0x6);
        // load value from slot
        // vm.load return a 32 bytes that needs to be casted to the mapping value type, here uint256
        data = vm.load(mappingStorageAccess, keccak256(bytes(abi.encodePacked(uint256Key, UINT256MAPPING_SLOT))));
        result = uint256(data);
        assertEq(result, 0x6);
    }
}
