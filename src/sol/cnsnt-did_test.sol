pragma solidity ^0.4.6;

import "dapple/test.sol";
import "cnsnt-did.sol";

contract ContractForward is Test {
  CDID did;

  function testInit() {
    did = new CDID(this);
  }
}
