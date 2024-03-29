pragma solidity ^0.4.9;

contract multiowned {

  // the number of owners that must confirm operations
  // before they are run.
  uint public m_required;

  // pointer used to find a free slot in m_owners
  uint public m_numOwners;

  // list of owners
  uint[256] m_owners;
  uint constant c_maxOwners = 250;

  // index on the list of owners to allow reverse lookup
  mapping(uint => uint) m_ownerIndex;

  // the ongoing operations.
  mapping(bytes32 => PendingState) m_pending;

  bytes32[] m_pendingIndex;

  // struct for the status of a pending operation
  struct PendingState {
    uint yetNeeded;
    uint ownersDone;
    uint index;
  }



	// EVENTS
  // ——————

  // This contract only has six types of events:
  // it can accept a confirmation, in which case we
  // record owner and operation (hash) alongside it

  event Confirmation(
    address owner,
    bytes32 operation
  );

  event Revoke(
    address owner,
    bytes32 operation
  );

  // Some others are in the case of an owner changing
  event OwnerChanged(
    address oldOwner,
    address newOwner
  );

  event OwnerAdded(
    address newOwner
  );

  event OwnerRemoved(
    address oldOwner
  );

  // The last one is emitted if the required signatures change
  event RequirementChanged(
    uint newRequirement
  );



	// MODIFIERS
  // —————————

  // Simple single-sig function modifier
  // ———————————————————————————————————
  modifier onlyowner {
    if (!isOwner(msg.sender)) throw;
    _;
  }

  // Multi-sig function modifier
  // ———————————————————————————
  // the operation must have an intrinsic hash in order that later
  // attempts can be realised as the same underlying operation and
  // thus count as confirmations.
  modifier onlymanyowners(bytes32 _operation) {
    if (!confirmAndCheck(_operation)) throw;
    _;
  }

  // CONSTRUCTOR
  // ———————————
  // given number of sigs required to do protected "onlymanyowners" txs
  // as well as the selection of addresses capable of confirming them.
  function multiowned(address[] _owners, uint _required) {
    m_numOwners = _owners.length;
    for (uint i = 0; i < _owners.length; ++i) {
      m_owners[1 + i] = uint(_owners[i]);
      m_ownerIndex[uint(_owners[i])] = 1 + i;
    }
    m_required = _required;
  }

  // Revokes a prior confirmation of the given operation
  function revoke(bytes32 _operation)
    external
  {
    uint ownerIndex = m_ownerIndex[uint(msg.sender)];
    // make sure they're an owner
    if (ownerIndex == 0) return;
    uint ownerIndexBit = 2**ownerIndex;
    var pending = m_pending[_operation];
    if (pending.ownersDone & ownerIndexBit > 0) {
      pending.yetNeeded++;
      pending.ownersDone -= ownerIndexBit;
      Revoke(msg.sender, _operation);
    }
  }

  // Replaces an owner `_from` with another `_to`.
  function changeOwner(address _from, address _to)
    onlymanyowners(sha3(msg.data))
    external
  {
    if (isOwner(_to)) return;
    uint ownerIndex = m_ownerIndex[uint(_from)];
    if (ownerIndex == 0) return;

    clearPending();
    m_owners[ownerIndex] = uint(_to);
    m_ownerIndex[uint(_from)] = 0;
    m_ownerIndex[uint(_to)] = ownerIndex;
    OwnerChanged(_from, _to);
  }

  function addOwner(address _owner)
    onlymanyowners(sha3(msg.data))
    external
  {
    if (isOwner(_owner)) return;

    clearPending();

    if (m_numOwners >= c_maxOwners) reorganizeOwners();
    if (m_numOwners >= c_maxOwners) return;

    m_numOwners++;
    m_owners[m_numOwners] = uint(_owner);
    m_ownerIndex[uint(_owner)] = m_numOwners;

    OwnerAdded(_owner);
  }

  function removeOwner(address _owner)
    onlymanyowners(sha3(msg.data))
    external
  {
    uint ownerIndex = m_ownerIndex[uint(_owner)];
    if (ownerIndex == 0) return;
    if (m_required > m_numOwners - 1) return;

    m_owners[ownerIndex] = 0;
    m_ownerIndex[uint(_owner)] = 0;
    clearPending();
    reorganizeOwners();
    // make sure m_numOwner is equal to the number of owners and
    // always points to the optimal free slot
    OwnerRemoved(_owner);
  }

  function changeRequirement(uint _newRequired)
    onlymanyowners(sha3(msg.data))
    external
  {
    if (_newRequired > m_numOwners) return;
    m_required = _newRequired;
    clearPending();
    RequirementChanged(_newRequired);
  }

  // Gets an owner by 0-indexed position
  // (using numOwners as the count)
  function getOwner(uint ownerIndex)
    external
    constant
    returns (address)
  {
    return address(m_owners[ownerIndex + 1]);
  }

  function isOwner(address _addr)
    returns (bool)
  {
    return m_ownerIndex[uint(_addr)] > 0;
  }

  function hasConfirmed(bytes32 _operation, address _owner)
    constant
    returns (bool)
  {
    var pending = m_pending[_operation];
    uint ownerIndex = m_ownerIndex[uint(_owner)];

    // make sure they're an owner
    if (ownerIndex == 0) return false;

    // determine the bit to set for this owner.
    uint ownerIndexBit = 2**ownerIndex;
    return !(pending.ownersDone & ownerIndexBit == 0);
  }

  // INTERNAL METHODS

  function confirmAndCheck(bytes32 _operation)
    internal
    returns (bool)
  {
    // determine what index the present sender is:
    uint ownerIndex = m_ownerIndex[uint(msg.sender)];

    // make sure they're an owner
    if (ownerIndex == 0) return;

    var pending = m_pending[_operation];

    // if we're not yet working on this operation,
    // switch over and reset the confirmation status.
    if (pending.yetNeeded == 0) {
      // reset count of confirmations needed.
      pending.yetNeeded = m_required;

      // reset which owners have confirmed (none)
      // set our bitmap to 0.
      pending.ownersDone = 0;
      pending.index = m_pendingIndex.length++;
      m_pendingIndex[pending.index] = _operation;
    }

    // determine the bit to set for this owner.
    uint ownerIndexBit = 2**ownerIndex;

    // make sure we (the message sender) haven't confirmed
    // this operation previously.
    if (pending.ownersDone & ownerIndexBit == 0) {

      Confirmation(msg.sender, _operation);

      // ok - check if count is enough to go ahead.
      if (pending.yetNeeded <= 1) {
        // enough confirmations: reset and run interior.
        delete m_pendingIndex[m_pending[_operation].index];
        delete m_pending[_operation];
        return true;
      } else {
        // not enough: record that this owner has confirmed.
        pending.yetNeeded--;
        pending.ownersDone |= ownerIndexBit;
      }
    }
  }

  function reorganizeOwners()
    private
  {
    uint free = 1;
    while (free < m_numOwners) {

      while (
        free < m_numOwners &&
        m_owners[free] != 0
      ) free++;

      while (
        m_numOwners > 1 &&
        m_owners[m_numOwners] == 0
      ) m_numOwners--;

      if (
        free < m_numOwners &&
        m_owners[m_numOwners] != 0 &&
        m_owners[free] == 0
      ) {
        m_owners[free] = m_owners[m_numOwners];
        m_ownerIndex[m_owners[free]] = free;
        m_owners[m_numOwners] = 0;
      }
    }
  }

  function clearPending()
    internal
  {
    uint length = m_pendingIndex.length;
    for (uint i = 0; i < length; ++i)
      if (m_pendingIndex[i] != 0)
        delete m_pending[m_pendingIndex[i]];
    delete m_pendingIndex;
  }
}
