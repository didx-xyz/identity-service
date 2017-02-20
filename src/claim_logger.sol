pragma solidity ^0.4.9;

/// @title  Consent Global - DID Claim Logger
/// @author Stephan Bothma <stephan@io.co.za>
contract Claim_Logger {

  uint public claim_ctr = 0;

  address public owner;

  event Claim(
    uint    claim_id,
    uint    against,
    bytes1  kind,
    string  claim,
    address addr_1,
    address addr_2,
    address origin,
    bool    by_owner
  );

  /// @notice Log a claim on this DID, optionally against a specific prior claim
  /// @param against   Previous claim ID to claim against, otherwise 0
  /// @param kind      Type of claim
  /// @param claim     Claim contents
  /// @param addr_1    Address 1 to link to claim
  /// @param addr_2    Address 1 to link to claim
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
      msg.sender == owner
    );
    return claim_ctr;
  }
}
