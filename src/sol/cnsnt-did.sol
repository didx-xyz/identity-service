pragma solidity ^0.4.9;

/** @title Consent DID */
contract CDID {

  // The "admin" keypair is allowed to forward calls through this relay and to replace itself.
  address public admin;

  // The "owner" keypair is only allowed to replace itself or the admin keypair
  address public owner;

  // Mapping to store key/value pairs
  mapping(string => string) kv_store;

  event claim(
    string log_message,
    bytes1 kind,
    address indexed addr_1,
    address indexed addr_2,
    address indexed origin
  );

  /**
   * @dev Creates a new instance of the proxy contract, with the supplied address as admin.
   * @param _admin The account to set as the admin of the new instance
   * @param _owner (optional) The owner of this CDID
   */
  function CDID(address _admin, address _owner) {
    admin = _admin;
    owner = _owner;

    // Ensure that the CDID has owner and admin keys set (default: msg.sender)
    if (admin == 0) admin = msg.sender;
    if (owner == 0) owner = admin;
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
   * Log/event data is not accessible from within contracts
   * Allow anyone to log a message on a contract instance (note that this doesn't allow them to impersonate the owner)
   */
  function log_please(
    string _log_message,
    bytes1 _kind,
    address _addr1,
    address _addr2
  ) {
    claim(_log_message, _kind, _addr1, _addr2, msg.sender);
  }

  function store(string _key, string _value) {
    if (msg.sender != admin) throw;
    kv_store[_key] = _value;
  }

  function retrieve(string _key) constant returns (string value) {
    value = kv_store[_key];
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
   * @param _new_owner Replacement address for owner
  */
  function change_owner(address _new_owner) {
    if (msg.sender != owner) throw;
    owner = _new_owner;
  }

  /**
   * @dev Token functionality
   */

  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) {
  }

  /** Accept ether transfers to this contract
   * @dev Allow the fallback function to be used
   */
  function() payable { }

}
