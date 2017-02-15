pragma solidity ^0.4.9;

contract didmInterface {
  function verify(address did) constant returns (string ddo);
  function update(string _ddo) returns (bool updated);
  function revoke() returns (bool revoked);
}
