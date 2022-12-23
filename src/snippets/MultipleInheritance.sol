// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";

abstract contract D {
    function f() public pure virtual returns (uint256) {
        return 0;
    }
}

abstract contract C is D {
    function f() public pure virtual override returns (uint256) {
        return 1;
    }
}

abstract contract B is C {
    function f() public pure override returns (uint256) {
        return 2 + super.f();
    }
}

// Multiple inheritance
// https://docs.soliditylang.org/en/develop/contracts.html#multiple-inheritance-and-linearization
// https://docs.soliditylang.org/en/develop/contracts.html#inheritance
contract A is B {
    function callParentsOfB() public pure returns (uint256 x, uint256 y, uint256 z) {
        x = f();
        y = C.f();
        z = D.f();
    }

    function callParent() public pure returns (uint256 x, uint256 y) {
        x = f();
        y = super.f();
        // Super call the function on the next contract in the inheritance sequence
        // A, B, C, D hence calls function in B
    }
}

contract TestMultipleInheritance is Test {
    A a;

    function setUp() public {
        a = new A();
    }

    function testMultipleInheritance() public {
        (uint256 x, uint256 y, uint256 z) = a.callParentsOfB();
        assertEq(x == 3, true);
        assertEq(y == 1, true);
        assertEq(z == 0, true);

        (x, y) = a.callParent();
        assertEq(x == 3, true);
        assertEq(y == 3, true);
    }
}
