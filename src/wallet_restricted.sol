pragma solidity ^0.4.9;

/// @title  Consent Global - DID Access Control Smart Contract
/// @author Stephan Bothma <stephan@io.co.za>
contract Restricted_Wallet {

  /// @notice Admin account of this Wallet
  address public r_adminkey;

  /// @notice Restrict calls to this contract to `r_adminkey` only
  address public r_registry;

  /// @notice Owner of this wallet
  address public owner; // Shared with Simplified_Wallet

  /// @dev Throw if message isn't being sent by administrator
  modifier onlyadmin {
    if ( msg.sender != r_adminkey ) throw;
    _;
  }

  /// @dev Throw if message isn't being sent by owner
  modifier onlyowner() {
    if (msg.sender != owner) throw;
    _;
  }

  /// @param t_receiver The address this transaction is sent to
  /// @dev Throws when a key, except `r_adminkey`, sends to `r_registry`
  modifier notrestricted (address t_receiver) {
    if ( t_receiver == r_registry
      && msg.sender != r_adminkey ) throw;
    _;
  }

  function isAdmin(address sender)
    returns (bool)
  {
    return sender == r_adminkey;
  }

  /// @dev   CONSTRUCTOR
  /// @param administrator Account of this CDID's administrator
  /// @param registry_addr The account address of the Registry
  function Restricted_Wallet (
    address administrator,
    address registry_addr
  ) {
    // Require administrator and registry_addr
    // (disallows default: 0 for both)
    if (administrator == 0) throw;
    if (registry_addr == 0) throw;

    r_adminkey = administrator;
    r_registry = registry_addr;
  }

  /// @dev   Event emitted when `r_admin` key is changed
  /// @param oldAdmin Admin key that was replaced
  /// @param newAdmin Key that controls the DID's registry contents
  event AdminChanged(
    address oldAdmin,
    address newAdmin
  );

  /// @notice Update which key controls your DID registry contents
  /// @dev    Change value of `r_adminkey` to `new_admin`
  /// @param  new_admin New admin account or proxy contract
  /// @return bool Update DID admin key success
  function updateAdminKey(address new_admin)
    onlyadmin()
    returns (bool updated)
  {
    // Store new address in r_adminkey
    r_adminkey = new_admin;

    // Emit event
    AdminChanged(msg.sender, new_admin);

    return true;
  }

  /// @notice Force change the Admin key
  /// @dev    Change value of `r_adminkey` to `new_admin` (forced by owner)
  /// @param  new_admin New admin account or proxy contract
  /// @return bool Update DID admin key success
  function forceAdminKeyUpdate(address new_admin)
    onlyowner()
    returns (bool updated)
  {
    var old_admin = r_adminkey;
    // Store new address in r_adminkey
    r_adminkey = new_admin;

    // Emit event
    AdminChanged(old_admin, new_admin);

    return true;
  }

}
