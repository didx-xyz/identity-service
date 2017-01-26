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

// These tests checks the `change_admin` function, which is used to hand over control of the proxy to another controller keypair/smart contract instance
contract CDIDChangeOwnerTest is Test {

  CDID did;

  Tester test_account_one;
  Tester test_account_two;

  // This function is run before _every_ test
  function setUp() {

    // Create two tester accounts:
    test_account_one = new Tester();
    test_account_two = new Tester();

    // Create a (orphan) did and set the first test account as its owner:
    did = new CDID(test_account_one, 0);

    // Set _both_ test accounts to target the did contract:
    test_account_one._target(did);
    test_account_two._target(did);
  }

  // Test if the `change_admin` method can be called passing in the second test account's address as param
  function testPassOnChangingOwner() {
    CDID(test_account_one).change_admin(test_account_two);
  }

  // Test that the `change_admin` method actually changes the owner of the proxy contract (tested by calling a[ny] method on the proxy from the second test account)
  function testPassOnSeriallyChangingOwner() {
    CDID(test_account_one).change_admin(test_account_two);
    CDID(test_account_two).change_admin(this);
  }

  // Test that the `change_admin` method can't be called from an arbitrary account
  function testFailOnUnauthorizedOwner() {
    CDID(test_account_two).change_admin(this);
  }

  // Test that the `change_admin` method can't be called from a previously replaced account
  function testFailOnReplacedOwner() {
    CDID(test_account_one).change_admin(test_account_two);
    CDID(test_account_one).change_admin(this);
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
