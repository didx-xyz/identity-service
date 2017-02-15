pragma solidity ^0.4.9;

import "wallet/wallet.sol";
import "did/claims.sol";
import "registry/interface.sol";

contract ConsentDID is Wallet, Claims {

  function ConsentDID(
    address owner,
    address admin,
    address didm
    )
    Wallet(
      wallet_constructor_helper(owner),
      1,
      1000000 ether
      )
    Restricted_Wallet(admin, didm)
  { }

  /// @dev transforms address to address[]
  function wallet_constructor_helper(address _owner)
    internal
    returns (address[] _owners)
  {
    _owners = new address[](1);
    _owners[0] = _owner;
  }

  function update_ddo(string new_ddo)
    onlyadmin()
    returns (bool updated)
  {
    return didmInterface(r_registry).update(new_ddo);
  }

  function revoke_ddo()
    onlyadmin()
    returns (bool revoked)
  {
    return didmInterface(r_registry).revoke();
  }

}
