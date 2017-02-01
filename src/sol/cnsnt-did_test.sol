pragma solidity ^0.4.6;

import "dapple/test.sol";
import "cnsnt-did.sol";

// Wrapper for ethereum log definitions, so they can be shared between the canary contract and the test contracts
contract Chirps {
  event Chirp();
  event FallBack();
  event TenWei();
  event ZeroWei();
}

// Dummy contract to tell if contract calls can be forwarded correctly
contract Canary is Chirps {

  // This function emits an event when called
  function chirp() {
    Chirp();
  }

  // Default function, emits different events, depending on whether 10 or 0 wei was deposited.
  function() payable {
    if (msg.value == 10) TenWei();
    if (msg.value == 0) ZeroWei();
  }
}

// These tests check the `forward` function, which is used to interact with other contracts/accounts on the network
contract CDIDForwardTest is Test, Chirps {

  Canary polly;
  CDID did;
  Tester test_account;
  bytes test_calldata;

  // this function is run on a before _every_ test, which gets run on a fresh instance of this contract.
  function setUp() {
    test_account = new Tester();
    polly = new Canary();
    did = new CDID(test_account, 0);
    test_account._target(did);
  }

  // test forwarding an empty calldata, zero wei
  function testForwardWithZeroWei() {
    // Create an empty (correctly typed) calldata variable
    bytes memory calldata;

    // Tell the testing harnass to check that the emitted and expected events match:
    expectEventsExact(polly);

    // Forward the contract call to the canary instance
    CDID(test_account).forward(polly, 0, calldata);

    // Emit the event to check against
    ZeroWei();
  }

  // test forwarding a valid function call, zero wei
  function testForwardWithZeroWeiAndCalldata() {
    // Create a valid function call:

    // Get the keccak hash of the function signature,
    bytes32 sig = sha3("chirp()");
    // ...and grab the first four bytes of the hash
    for (uint i = 0; i < 4; i++) {
      test_calldata.push(sig[i]);
    }

    expectEventsExact(polly);

    CDID(test_account).forward(polly, 0, test_calldata);
    Chirp();
  }

  // test forwarding a invalid/missing function call, zero wei
  function testForwardWithZeroWeiAndInvalidCalldata() {
    // Creating an invalid function call (scambled function signature)

    // Get the keccak hash of an invalid function signature,
    bytes32 sig = sha3("tweet()");

    // ...and grab the first four bytes of the hash
    for (uint i = 1; i < 5; i++) {
      test_calldata.push(sig[i]);
    }

    expectEventsExact(polly);

    CDID(test_account).forward(polly, 0, test_calldata);

    ZeroWei();
  }
}

// There tests check the `forward` call, in the case funds should be forwarded
contract CDIDFundedForwardTest is Test, Chirps {

  CDID did;
  Canary polly;

  function setUp() {
    did = new CDID(this, 0);
    polly = new Canary();
    // Here we fund the did (before every test)
    bool success = did.send(100);
  }

  // Test whether the did instance received the 100 wei stipend
  function testDidBalance() {
    log_uint(did.balance);
    assertEq(100, did.balance);
  }

  // Test if the did can forward 10 wei to the canary contract, checking for the TenWei() event
  function testPassForwardTenWei() {
    bytes memory empty_calldata;

    expectEventsExact(polly);

    did.forward(polly, 10, empty_calldata);
    TenWei();
  }

  // Test if the did can forward 10 wei into the canary contract, checking that the balances of each changed
  function testAssertBalance() {
    log_named_uint("consent did pre transfer", did.balance);
    assertEq(100, did.balance);
    log_named_uint("test canary pre transfer", polly.balance);
    assertEq(0, polly.balance);

    bytes memory empty_calldata;
    did.forward(polly, 10, empty_calldata);

    log_named_uint("consent did post transfer", did.balance);
    assertEq(90, did.balance);
    log_named_uint("test canary post transfer", polly.balance);
    assertEq(10, polly.balance);

  }
}

contract CDIDAdminOwnerTest is Test, Chirps {

  CDID did;
  Tester admin;
  Tester owner;
  Canary polly;
  bytes calldata;

  function setUp() {
    polly = new Canary();
    admin = new Tester();
    owner = new Tester();

    did = new CDID(admin, owner);

    admin._target(did);
    owner._target(did);
  }

  function testFailChangeOwnerWithAdmin() {
    CDID(admin).change_owner(this);
  }

  function testFailChangeAdminWithUnknown() {
    CDID(this).change_admin(owner);
  }

  function testFailForwardByOwner() {
    CDID(owner).forward(polly, 0, calldata);
  }

  function testPassForwardByAdmin() {
    CDID(admin).forward(polly, 0, calldata);
  }
}

contract CDIDadminOwnerTest is Test {
  CDID did;
  Tester admin;
  Tester owner;

  function setUp() {
    admin = new Tester();
    owner = new Tester();
  }

  function testNoAdminFallback() {
    did = new CDID(0, owner);
    address admin_read = did.admin();
    address owner_read = did.owner();
    assertEq(this, admin_read);
    assertEq(owner, owner_read);
  }

  function testNoOwnerFallback() {
    did = new CDID(admin, 0);
    address admin_read = did.admin();
    address owner_read = did.owner();
    assertEq(admin, admin_read);
    assertEq(admin, owner_read);
  }

  function testNoOwnerNoAdminFallback() {
    did = new CDID(0, 0);
    address admin_read = did.admin();
    address owner_read = did.owner();
    assertEq(this, admin_read);
    assertEq(this, owner_read);
  }

  function testOwnerAdmin() {
    did = new CDID(admin, owner);
    address admin_read = did.admin();
    address owner_read = did.owner();
    assertEq(admin, admin_read);
    assertEq(owner, owner_read);
  }
}

contract CDIDLoggingTest is Test {

  CDID did;
  Tester admin;
  Tester owner;

  event claim(
    string log_message,
    bytes1 kind,
    address indexed addr_1,
    address indexed addr_2,
    address indexed origin
  );

  function setUp() {
    admin = new Tester();
    owner = new Tester();

    did = new CDID(admin, owner);

    admin._target(did);
    owner._target(did);
  }

  function testPassLog() {
    expectEventsExact(did);

    did.log_please(
      "this is a test message this is a test message this is a test message this is a test message this is a test message",
      0x43,
      owner,
      admin
    );

    claim(
      "this is a test message this is a test message this is a test message this is a test message this is a test message",
      0x43,
      owner,
      admin,
      this
    );
  }

  function testPassLogEmpty() {
    expectEventsExact(did);
    did.log_please("", 0x0, 0x0, 0x0);
    claim("", 0x0, 0x0, 0x0, this);
  }
}

// Utility contract to enable logging from storage, because we can't transport strings between contracts.
contract CDIDCanary is CDID {
  event storageLog(string value);

  function logStorage(string _key) {
    storageLog(kv_store[_key]);
  }

  function CDIDCanary(address _admin, address _owner)
  CDID(_admin, _owner) {}

}

contract CDIDStorageTest is Test {
  CDIDCanary did;
  Tester admin;
  Tester owner;

  event storageLog(string value);

  function setUp() {
    admin = new Tester();
    owner = new Tester();

    did = new CDIDCanary(admin, owner);

    admin._target(did);
    owner._target(did);
  }

  function testFailStoreByOwner() {
    CDIDCanary(owner).store("test_key", "test_value");
  }

  function testPassStoreByOwner() {
    CDIDCanary(admin).store("test_key", "test_value");
  }

  function testRetrieve() {
    CDIDCanary(admin).store("test_key", "test_value");

    /*retrieved = CDID(admin).retrieve("test_key");*/
    /*assertEq(retrieved, "test_value");*/

    expectEventsExact(did);
    CDIDCanary(admin).logStorage("test_key");
    storageLog("test_value");
  }
}
