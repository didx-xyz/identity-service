pragma solidity ^0.4.9;

contract registry_interface {
  function verify(address did) constant returns (string ddo);
  function update(string ddo) returns (bool updated);
  function revoke(
    bool revocation_is_temporary,
    address else_did_to_revoke_permanently
  ) returns (bool revoked);
}
