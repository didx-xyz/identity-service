pragma solidity ^0.4.6;

import "dapple/test.sol";
import "didm-registry.sol";

contract DIDM_logging_events {
  event LogDDO(string _ddo);
  event LogDidCount(uint _did_count);
}

contract DIDM_with_logging is DIDM, DIDM_logging_events {
  function emit_verify(address consent_did) {
    // LogDDO(this.verify(consent_did)); <-- This doesn't work because solidity/EVM can't transport strings between contracts, we'll use the test runners log matching facility to bypass this.
    string ddo = ddo_value[did_key[consent_did]]; // <-- This line should duplicate the body of the #verify method in the DIDM contract
    LogDDO(ddo);
  }
}

contract DidmAdminOwnerTest is Test {
  DIDM registry;
  CDID did;
  Tester tester1;
  Tester tester2;

  event created(address did, address admin, address owner);

  function setUp() {
    registry = new DIDM();
    tester1 = new Tester();
    tester2 = new Tester();
  }

  function testEventNoAdminNoOwner() {
    expectEventsExact(registry);
    address did_address = registry.create('', 0, 0);
    created(did_address, this, this);
  }

  function testEventNoAdmin() {
    expectEventsExact(registry);
    address did_address = registry.create('', 0, tester2);
    created(did_address, this, tester2);
  }

  function testEventNoOwner() {
    expectEventsExact(registry);
    address did_address = registry.create('', tester1, 0);
    created(did_address, tester1, tester1);
  }

  function testEventBoth() {
    expectEventsExact(registry);
    address did_address = registry.create('', tester1, tester2);
    created(did_address, tester1, tester2);
  }
}

contract DIDMCreateTest is Test {
  DIDM registry;
  CDID did;
  bytes calldata;
  Tester tester;
  Tester tester2;

  event created(address did, address admin, address owner);

  function setUp() {
    registry = new DIDM();
    tester = new Tester();
    tester2 = new Tester();
  }

  function testCreateDidAddress() {
    address did_address = registry.create('test_ddo', 0, 0);
    log_address(did_address);
  }

  function testCreatedValidDidInstance() {
    address did_address = registry.create('test_ddo', 0, 0);
    CDID(did_address).change_admin(this);
  }

  function testCreatedDidEvent() {
    expectEventsExact(registry);
    address did_address = registry.create('test_ddo', 0, 0);
    created(did_address, this, this);
  }

  function testCreatedDidEventSponsored() {
    expectEventsExact(registry);
    address did_address = registry.create('test_ddo', tester, 0);
    created(did_address, tester, tester);
  }


}

contract DIDMCreateSponsored is Test {
  DIDM registry;
  CDID did;
  bytes calldata;
  Tester tester;
  Tester jester;

  function setUp() {
    registry = new DIDM();
    tester = new Tester();
    jester = new Tester();
  }

  function testCreateOwn() {
    address did_address = registry.create('', 0, 0);
    CDID(did_address).change_admin(this);
  }

  function testCreateSponsored() {
    address did_address = registry.create('', tester, 0);
    tester._target(did_address);
    CDID(tester).change_admin(this);
  }

  function testThrowCreateSponsored() {
    address did_address = registry.create('', tester, 0);
    jester._target(did_address);
    CDID(jester).change_admin(this);
  }
}

contract DIDMUpdateTest is Test, DIDM_logging_events {
  DIDM_with_logging registry;
  address did_address;
  bytes calldata;
  CDID did;

  // _before every_ test, on a fresh instance of `this` contract:
  function setUp() {
    registry = new DIDM_with_logging();
    did_address = registry.create('test_ddo', 0, 0);
    did = CDID(did_address);
  }

  // Test that the ddo set with the create call actually exists
  function testDdoExists() {
    expectEventsExact(registry);
    registry.emit_verify(did_address);
    LogDDO('test_ddo');
  }

  // This test confirms that the previous test won't soft fail
  function testFailExpectingWrongDdo() {
    expectEventsExact(registry);
    registry.emit_verify(did_address);
    LogDDO('wrong_test_ddo');
  }

  // This test confirms that the DDO is actually changed
  function testChangeDdo() {
    // Start by building (bytes) calldata. The resultant bytes variable contains a valid ethereum call `update(updated_test_ddo)`
    bytes32 test1 = 0x3d7403a300000000000000000000000000000000000000000000000000000000;
    bytes32 test2 = 0x0000002000000000000000000000000000000000000000000000000000000000;
    bytes32 test3 = 0x00000010757064617465645f746573745f64646f000000000000000000000000;
    bytes4 test4 = 0x00000000;

    for (uint i = 0; i < 32; i++) {
      calldata.push(test1[i]);
    }
    for (uint j = 0; j < 32; j++) {
      calldata.push(test2[j]);
    }
    for (uint k = 0; k < 32; k++) {
      calldata.push(test3[k]);
    }
    for (uint l = 0; l < 4; l++) {
      calldata.push(test4[l]);
    }

    // Use the did created in setUp() to proxy the calldata to the registry
    did.forward(registry, 0, calldata);

    // Tell the testing harnass to expect the updated ddo string in the logs
    expectEventsExact(registry);

    // Tell the (modified) registry to emit the ddo currently set against the did_address belonging to `this` contract.
    registry.emit_verify(did_address);
    LogDDO('updated_test_ddo');
  }

  // Test that calling revoke from an unregistered address throws
  function testThrowUnregisteredUpdate() {
    registry.update('this should fail');
  }
}

contract DIDMRevokeTest is Test, DIDM_logging_events {
  DIDM_with_logging registry;
  address did_address;
  bytes calldata;
  CDID did;

  function setUp() {
    registry = new DIDM_with_logging();
    did_address = registry.create('test_ddo', 0, 0);
    did = CDID(did_address);
  }

  function testRevokeCall() {
    // Create a valid function call:

    // Get the keccak hash of the function signature,
    bytes32 sig = sha3("revoke()");
    // ...and grab the first four bytes of the hash
    for (uint i = 0; i < 4; i++) {
      calldata.push(sig[i]);
    }

    did.forward(registry, 0, calldata);
  }

  function testRevokeCallEffect() {
    // Create a valid function call:

    // Get the keccak hash of the function signature,
    bytes32 sig = sha3("revoke()");
    // ...and grab the first four bytes of the hash
    for (uint i = 0; i < 4; i++) {
      calldata.push(sig[i]);
    }

    did.forward(registry, 0, calldata);

    // Tell the test runner to expect duplicate events
    expectEventsExact(registry);
    // Emit a blank LogDDO event
    LogDDO('');
    // Make the (modified) registry log out the DDO matching the did_address
    registry.emit_verify(did_address);
  }

  // Test that calling revoke from an unregistered address throws
  function testThrowUnregisteredRevoke() {
    registry.revoke();
  }
}
