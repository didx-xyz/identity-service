pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./IdentityService.sol";

contract IdentityServiceTest is DSTest {
    IdentityService service;

    function setUp() public {
        service = new IdentityService();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
