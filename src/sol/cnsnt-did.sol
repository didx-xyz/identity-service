pragma solidity ^0.4.6;

/** @title Consent DID */
contract CDID {

  address controller;

  /**
   * @dev Creates a new instance of the proxy contract, with the supplied address as controller.
   * @param _controller The account to set as the controller of the new instance
   */
  function CDID(address _controller) {
    controller = _controller;
  }


  /**
   * @dev Forward any wei and calldata to the specified address, throwing if the call doesn't succeed
   * @param _to The address to forward the call to
   * @param _wei The amount of wei to forward along with the call (from the CDID's balance)
   * @param _calldata The calldata to
   */
  function forward(address _to, uint _wei, bytes _calldata) {
    if (msg.sender != controller) throw;
    if (!_to.call.value(_wei)(_calldata)) throw;
  }

  /**
   * @dev Change the owner of this Consent DID to any account/contract instance (this contract doensn't check that the address exists!)
   * @param _new_controller The account to set as the new controller of the Consent DID
   */
  function change_controller(address _new_controller) {
    if (msg.sender != controller) throw;
    controller = _new_controller;
  }

  /** Accept ether transfers to this contract
   * @dev Allow the fallback function to be used
   */
  function() payable { }

}
