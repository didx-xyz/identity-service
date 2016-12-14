pragma solidity ^0.4.6;

import "dapple/test.sol";
import "cnsnt-did.sol";

contract ChangeOwnerTest is Test {

  CDID did;

  Tester test_account_one;
  Tester test_account_two;

  // This function is run before _every_ test
  function setUp() {
    // Create two tester accounts:
    test_account_one = new Tester();
    test_account_two = new Tester();

    // Create a (orphan) did and set the first test account as its owner:
    did = new CDID(test_account_one);

    // Set _both_ test accounts to target the did contract:
    test_account_one._target(did);
    test_account_two._target(did);
  }

  // Test if the `change_owner` method can be called passing in the second test account's address as param
  function testPassOnChangingOwner() {
    CDID(test_account_one).change_owner(test_account_two);
  }

  // Test that the `change_owner` method actually changes the owner of the proxy contract (tested by calling a[ny] method on the proxy from the second test account)
  function testPassOnSeriallyChangingOwner() {
    CDID(test_account_one).change_owner(test_account_two);
    CDID(test_account_two).change_owner(this);
  }

  // Test that the `change_owner` method can't be called from an arbitrary account
  function testFailOnUnauthorizedOwner() {
    CDID(test_account_two).change_owner(this);
  }

  // Test that the `change_owner` method can't be called from a previously replaced account
  function testFailOnReplacedOwner() {
    CDID(test_account_one).change_owner(test_account_two);
    CDID(test_account_one).change_owner(this);
  }

}
