pragma solidity ^0.4.6;

/** @title Consent DID */
contract CDID {

  // The "admin" keypair is allowed to forward calls through this relay and to replace itself.
  address public admin;

  // The "owner" keypair is only allowed to replace itself or the admin keypair
  address public owner;

  /**
   * @dev Creates a new instance of the proxy contract, with the supplied address as admin.
   * @param _admin The account to set as the admin of the new instance
   * @param _owner (optional) The owner of this CDID
   */
  function CDID(address _admin, address _owner) {
    admin = _admin;
    owner = _owner;
  }

  /**
   * @dev Forward any wei and calldata to the specified address, throwing if the call doesn't succeed
   * @param _to The address to forward the call to
   * @param _wei The amount of wei to forward along with the call (from the CDID's balance)
   * @param _calldata The calldata to
   */
  function forward(address _to, uint _wei, bytes _calldata) {
    if (msg.sender != admin) throw;
    if (!_to.call.value(_wei)(_calldata)) throw;
  }

  /**
   * @dev Change the owner of this Consent DID to any account/contract instance (warning: this contract doensn't check that the address exists!)
   * @param _new_admin The account to set as the new admin of the Consent DID
   */
  function change_admin(address _new_admin) {
    if (msg.sender != admin && msg.sender != owner) throw;
    admin = _new_admin;
  }

  /**
   * @dev Change the owner key of this instance
  */
  function change_owner(address _new_owner) {
    if (msg.sender != owner) throw;
    owner = _new_owner;
  }

  /** Accept ether transfers to this contract
   * @dev Allow the fallback function to be used
   */
  function() payable { }

}
