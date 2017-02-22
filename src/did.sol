pragma solidity ^0.4.9;

import "interface_registry.sol";
import "wallet_simplified.sol";
import "claim_logger.sol";

/// @title  Consent Global - DID Smart Contract
/// @author Stephan Bothma <stephan@io.co.za>
contract Consent_DID is Claim_Logger, Simplified_Wallet {

  /// @dev   CONSTRUCTOR
  /// @param owner_pb Address of owner (account or proxy contract)
  /// @param admin_pb Address of admin (account or proxy contract)
  /// @param registry Address of Registry linked to this contract
  function Consent_DID (
    address owner_pb,
    address admin_pb,
    address recovery,
    address registry
  )
    Simplified_Wallet(owner_pb, recovery)
    Restricted_Wallet(admin_pb, registry)
  { }

  /// @notice Update your DID's contents on the Registry
  /// @dev    Only executable by `admin_pb`
  /// @param  did_value String to store on the Registry
  /// @return bool updated Update registry content success
  function updateDidContent(
    string did_value
  )
    onlyadmin()
    returns (bool updated)
  {
    return registry_interface(r_registry).update(did_value);
  }

  /// @notice Revoke your DID's contents on the Registry
  /// @dev    Only executable by `admin_pb`
  /// @return bool revoked Revoke registry content success
  function revokeDidContent()
    onlyadmin()
    returns (bool revoked)
  {
    return registry_interface(r_registry).revoke(false, 0);
  }

}
