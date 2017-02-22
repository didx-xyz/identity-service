pragma solidity ^0.4.9;

// Import Consent_DID contract
import "did.sol";

/// @title  Consent Global - DID Registry Contract
/// @author Stephan Bothma <stephan@io.co.za>
contract DIDM_Registry {

  // Map DID address to uint (to DID content string)
  // This allows us to see if a DID is empty, unassigned or revoked
  // Empty DID's map to did_key > 0, unassigned to 0, revoked to -1
  mapping (address => uint) did_key;
  mapping (uint => string) did_val;

  // Internal DID counter, used to assign `did_key`
  uint public did_count = 0;

  /// @dev Event emitted when Registry successfully spawns DID Contract
  /// @param did    Address of the DID instance that was spawned
  /// @param sender Account that payed gas costs for this transaction
  /// @param owner  Account of owner of the DID instance
  /// @param admin  Account of administrator of DID instance
  /// @param ddo    DDO set on initialization of this contract
  event CreatedDID(
    address did,
    address sender,
    address owner,
    address admin,
    string  ddo
  );

  /// @dev Event emitted when a DID is updated
  /// @param did The DID address
  event UpdatedDID(
    address did
  );

  /// @dev Event emitted when a DID is revoked
  /// @param did The DID address
  /// @param permanent The DID has been permanently revoked
  event RevokedDID(
    address did,
    bool permanent
  );

  /// @notice Create a self sovereign Consent DID
  /// @param  owner Account that will control the wallet features and keys
  /// @param  admin Account that can update DID content (can be same as `owner`)
  /// @param  ddo   Initial DDO of this contract (can be updated later)
  /// @return did   Address of the newly created DID
  function create(
    address owner,
    address admin,
    string  ddo
  )
    returns (address did)
  {
    // Don't let DID's create other DID's
    if (did_key[msg.sender] != 0) throw;

    // Require _owner and _admin keys to be set
    if (owner == 0) throw;
    if (admin == 0) throw;

    // Spin up the did contract, passing `this` as `registry` value
    did = new Consent_DID(owner, admin, this);

    // Edge case where the generated consent did is already registered (untestable), but will prevent the current DDO from being overwritten
    if (did_key[did] != 0) throw;

    // Increment the did_count and assign the did_index for the new DID
    uint did_index = ++did_count;

    // Create the new did_record
    did_key[did] = did_index;

    // Set the ddo on the new did_record
    did_val[did_index] = ddo;

    // Emit event
    CreatedDID(did, msg.sender, owner, admin, ddo);
  }

  /// @notice Retrieve/verify the contents of a specific DID
  /// @param  did The requested DID address
  /// @return ddo The DID contents
  /// @dev Use didExists(did) and didRevoked(did) for additional info
  function verify(address did) constant returns (string ddo) {
    ddo = did_val[did_key[did]];
  }

  /// @notice Check if a DID exists
  /// @param  did    The DID address to look up
  /// @return exists The DID exists on this Registry
  function didExists(address did) constant returns (bool exists) {
    exists = did_key[did] != 0;
  }

  /// @notice Check if a DID has been permanently revoked
  /// @param  did     The DID address to look up
  /// @return revoked The DID existed, but has been permanently revoked
  function didRevoked(address did) constant returns (bool revoked) {
    revoked = did_key[did] == -1;
  }

  /// @notice Update the DID's content (the "DDO")
  /// @param  ddo     The new DID content
  /// @return updated DID update success
  function update(string ddo) returns (bool updated) {
    if (did_key[msg.sender] < 1) throw;

    // Set the new record
    did_val[did_key[msg.sender]] = ddo;

    // Emit event
    UpdatedDID(msg.sender);
    return true;
  }

  /// @notice Revoke your DID on *this* Registry (without disabling wallet features)
  /// @param revocation_is_temporary Set to `true` to temporarily revoke your DID content (you can undo this later), otherwise set this to `false` AND confirm your DID address in the next field to confirm that you require permanent revocation of your DID on this Registry.
  /// @param else_did_to_revoke_permanently Set this to your DID address to confirm permanent revocation.
  function revoke(
    bool    revocation_is_temporary,
    address else_did_to_revoke_permanently
  )
    returns (bool revoked)
  {
    if (did_key[msg.sender] < 1) throw;

    // Temporary revocation (suspension), set DDO to empty string
    if (revocation_is_temporary) {
      did_val[did_key[msg.sender]] = "";

      // Emit event
      RevokedDID(msg.sender, false);
      return true;
    }
    else {
      // Safety catch
      if (else_did_to_revoke_permanently != msg.sender) throw;

      // Empty the old did_val
      did_val[did_key[msg.sender]] = "";

      // Mark the did_key as revoked
      did_key[msg.sender] = -1;

      // Emit event
      RevokedDID(msg.sender, true);
      return true;
    }
  }
}
