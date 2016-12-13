pragma solidity ^0.4.4;

contract CDID {

  address owner;

  function CDID(address _owner) {
    owner = _owner;
  }

  function forward(address _to, uint _wei, bytes _calldata) {
    if (msg.sender != owner) throw;
    if (!_to.call.value(_wei)(_calldata)) throw;
  }

  function change_owner(address _new_owner) {
    if (msg.sender != owner) throw;
    owner = _new_owner;
  }

}
