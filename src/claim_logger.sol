pragma solidity ^0.4.9;

import "interface_wallet.sol";

/// @title  Consent Global - DID Claim Logger
/// @author Stephan Bothma <stephan@io.co.za>
contract Claim_Logger is wallet_interface {

  // Internal Claim counter
  uint public claim_ctr = 0;

  /// @dev Event emitted when any external party makes a claim against this DID
  /// @param claim_id ID of the claim on this DID
  /// @param against Previous claim_id the current claim applies to
  /// @param kind Single byte identifier for the "kind" of claim
  /// @param claim Stringified claim contents
  /// @param addr_1 First additional address this claim applies to
  /// @param addr_2 Second additional address this claim applies to
  /// @param origin The account this claim originated from
  /// @param by_owner Whether the claim was made by the owner of the DID (at the time the claim was made)
  /// @param by_admin Whether the claim was made by the admin of the DID (at the time the claim was made)
  event Claim(
    uint    claim_id,
    uint    against,
    bytes1  kind,
    string  claim,
    address addr_1,
    address addr_2,
    address origin,
    bool    by_owner,
    bool    by_admin
  );

  /// @notice Log a claim on this DID, optionally against a specific prior claim
  /// @param  against  Previous claim ID to claim against, otherwise 0
  /// @param  kind     Type of claim
  /// @param  claim    Claim contents
  /// @param  addr_1   Address 1 to link to claim
  /// @param  addr_2   Address 1 to link to claim
  /// @return claim_id ID of claim on this DID
  function logClaim(
    uint    against,
    bytes1  kind,
    string  claim,
    address addr_1,
    address addr_2
  )
    returns (uint claim_id)
  {
    Claim(
      ++claim_ctr,
      against,
      kind,
      claim,
      addr_1,
      addr_2,
      msg.sender,
      isOwner(msg.sender),
      isAdmin(msg.sender)
    );
    return claim_ctr;
  }
}
