pragma solidity ^0.4.8;

import "cnsnt-did.sol";

/** @title Consent DIDM Registry */
contract DIDM {

  mapping (address => uint) did_key;
  mapping (uint => string) ddo_value;

  uint public did_count = 0;

  event created(address did, address admin, address owner);

  /**
   * @dev Creates a new instance of the CDID contract
   * @param _ddo DDO to set for the new DID
   * @return new_did Address of the newly created DID
   */
  function create(
    string  _ddo,
    address _admin,
    address _owner
  ) returns (
    address new_did
  ) {
    // Only allow one ddo per top level cdid
    if (did_key[msg.sender] != 0) throw;

    address admin = _admin;
    address owner = _owner;

    /*

      Both admin and owner 0: use msg.sender
      Both admin and owner specified: use as is

      Owner unspecified: owner = admin
      Admin unspecified: admin = msg.sender

    */

    // Fall back to setting owner as admin if unspecified
    if (admin == 0) admin = msg.sender;

    // Fall back to setting transaction signer as owner if unspecified
    if (owner == 0) owner = admin;


    // Spin up the did contract
    new_did = new CDID(admin, owner);

    // Edge case where the generated consent did is already registered (untestable), but will prevent the current DDO from being overwritten
    if (did_key[new_did] != 0) throw;

    uint new_did_index = ++did_count;

    // Create the new did_record
    did_key[new_did] = new_did_index;

    // Set the ddo on the new did_record
    ddo_value[new_did_index] = _ddo;

    // Emit event
    created(new_did, admin, owner);
  }

  /**
   * @dev Verify/Read the DDO entry for a specified DID
   * @param consent_did DID to look up
   * @return ddo The matching DDO entry for the DID
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
