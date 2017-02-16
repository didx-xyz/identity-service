pragma solidity ^0.4.9;

import "wallet/lightweight.sol";
import "did/claims.sol";
import "registry/interface.sol";

contract Consent_DID is Lightweight_Wallet, Claims {

  function Consent_DID (
    address owner,
    address admin,
    address didm
    )
    Lightweight_Wallet(owner)
    Restricted_Wallet(admin, didm)
  { }

  function updateDDO(string new_ddo)
    onlyadmin()
    returns (bool updated)
  {
    return didmInterface(r_registry).update(new_ddo);
  }

  function revokeDDO()
    onlyadmin()
    returns (bool revoked)
  {
    return didmInterface(r_registry).revoke();
  }

}
