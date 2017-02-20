pragma solidity ^0.4.9;

import "wallet_restricted.sol";

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

  address public owner;
  address[2] public m_owners;
  uint public constant m_required = 1;
  uint public constant m_numOwners = 1;

  modifier onlyowner() {
    if (msg.sender != owner) throw;
    _;
  }

  function Lightweight_Wallet(
    address _owner
  ) {
    owner = _owner;
    m_owners[1] = _owner; // backwards compatibility
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
    onlyowner
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
