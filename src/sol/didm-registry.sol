pragma solidity ^0.4.4;

import "cnsnt-did";

/** @title Consent DIDM Registry */
contract DIDM {

  mapping (address => uint) did_key;
  mapping (uint => string) ddo_value;

  uint public didCount = 0;

  event created(address did);

  /**
   * @dev Creates a new instance of the CDID contract
   * @param _ddo DDO to set for the new DID
   * @returns new_did Address of the newly created DID
   */
  function create(string _ddo) returns (address new_did) {
    // Only allow one ddo per did
    if (did_key[msg.sender] != 0) throw;

    uint new_did_index = ++didCount;

    // Spin up the did contract
    new_did = new CDID(msg.sender, this);

    // Create the new did_record
    did_key[new_did] = new_did_index;

    // Set the ddo on the new did_record
    ddo_value[new_did_index] = _ddo;

    // Emit event
    created(new_did);
  }

  /**
   * @dev Verify/Read the DDO entry for a specified DID
   * @param consent_did DID to look up
   * @returns ddo The matching DDO entry for the DID
   */
  function verify(address consent_did) constant returns (string ddo) {
    ddo = ddo_value[did_key[consent_did]];
  }

  /**
   * @dev Update the DDO entry matching the sender's address
   * @param _ddo New DDO to set
   */
  function update(string _ddo) {
    if (did_key[msg.sender] == 0) throw;
    ddo_value[did_key[msg.sender]] = _ddo;
  }

  /**
   * @dev Sets the DDO entry for the sender's address to an empty string
   */
  function revoke() {
    if (did_key[msg.sender] == 0) throw;
    ddo_value[did_key[msg.sender]] = "";
  }
}
