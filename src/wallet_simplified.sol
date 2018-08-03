pragma solidity ^0.4.9;

import "./wallet_restricted.sol";

contract Simplified_Wallet is Restricted_Wallet {

  event SingleTransact(
    address owner,
    uint    value,
    address to,
    bytes   data
  );

  event Deposit(
    address _from,
    uint    value
  );

  event OwnerChanged(
    address oldOwner,
    address newOwner
  );

  event RecoveryKeyChanged(
    address oldRecovery,
    address newRecovery
  );

  address public owner;

  /// @dev Nominated Recovery Key
  address public recovery;

  // Backwards compatibility with Ethereum Wallet:
  address[2] public m_owners;
  uint public constant m_required = 1;
  uint public constant m_numOwners = 1;

  modifier onlyowner() {
    if (msg.sender != owner) throw;
    _;
  }

  modifier onlyrecovery() {
    if (msg.sender != recovery) throw;
    _;
  }

  function Simplified_Wallet(
    address _owner,
    address _recovery
  ) {
    if (_owner == 0) throw;
    if (_recovery == 0) throw;
    owner = _owner;
    recovery = _recovery;
    // backwards compatibility:
    m_owners[1] = _owner;
  }

  /// @notice Nominate a new recovery key that is able to replace the owner account in case control of the owner account is lost. (Only owner)
  /// @param _recovery Recovery account address
  /// @return updated Update success
  function nominateRecoveryKey(
    address _recovery
  )
    onlyowner()
    returns (bool updated)
  {
    // Don't allow owner key to match recovery key
    if (msg.sender == _recovery) throw;
    if (_recovery == 0) throw;
    RecoveryKeyChanged(recovery, _recovery);
    recovery = _recovery;
    return true;
  }

  /// @notice Replace the recovery key (Only recovery key)
  /// @param _recovery Updated recovery account
  /// @return updated Update success
  function updateRecoveryKey(
    address _recovery
  )
    onlyrecovery()
    returns (bool updated)
  {
    if (recovery == _recovery) throw;
    RecoveryKeyChanged(recovery, _recovery);
    recovery = _recovery;
    return true;
  }

  /// @notice Replace the owner account of the Wallet and DID using the recovery key. DO NOT USE THIS TO TRANSFER OWNERSHIP BETWEEN INDIVIDUALS!
  /// @param new_owner The account that becomes the owner of the Wallet
  function recoverOwnership(address new_owner)
    onlyrecovery()
    returns (bool)
  {
    if (new_owner == owner) throw;
    OwnerChanged(owner, new_owner);
    owner = new_owner;
    return true;
  }

  function changeOwner(
    address _from,
    address _to
  )
    onlyowner()
    external
  {
    owner = _to;
    m_owners[1] = _to;
    OwnerChanged(_from, _to);
  }

  function getOwner(uint ownerIndex)
    external
    constant
    returns (address)
  {
    return m_owners[ownerIndex + 1];
  }

  function isOwner(address _addr) returns (bool) {
    return _addr == owner;
  }

  function execute(
    address _to,
    uint    _value,
    bytes   _data
  )
    external
    notrestricted(_to)
    onlyowner()
    returns (bytes32 _r)
  {
    SingleTransact(msg.sender, _value, _to, _data);
    if (!_to.call.value(_value)(_data)) throw;
    return 0;
  }

  function()
    payable
  {
    if (msg.value > 0) {
      Deposit(msg.sender, msg.value);
    }
  }
}
