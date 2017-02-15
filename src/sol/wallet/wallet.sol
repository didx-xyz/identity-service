// Multi-sig, daily-limited account proxy/wallet
// —————————————————————————————————————————————
// @author: Gav Wood <g@ethdev.com>

// Inheritable "property" contract that enables methods to be protected
// by requiring the acquiescence of either a single, or, crucially, each
// of a number of, designated owners.

// Usage:
// ——————
// Use modifiers `onlyowner` (just own owned) or `onlymanyowners(hash)`,
// whereby the same hash must be provided by some number (specified in
// constructor) of the set of owners (specified in the constructor,
// modifiable) before the interior is executed.

pragma solidity ^0.4.9;

import "wallet/multisig.sol";
import "wallet/multiowned.sol";
import "wallet/daylimit.sol";

// Usage:
// ——————
// bytes32 h = Wallet(w).from(oneOwner).execute(to, value, data);
// Wallet(w).from(anotherOwner).confirm(h);

contract Wallet is multisig, multiowned, daylimit {

  // Transaction structure
  // —————————————————————
  // to store details of transaction lest it need be saved for a later call.
  struct Transaction {
    address to;
    uint    value;
    bytes   data;
  }

  // pending transactions we have at present
  // ———————————————————————————————————————
  mapping (bytes32 => Transaction) m_txs;

  // CONSTRUCTOR
  // ———————————
  // just pass on the owner array to the `multiowned` and,
  // the limit to `daylimit`
  function Wallet(
    address[] _owners,
    uint      _required,
    uint      _daylimit
  )
    multiowned(
      _owners,
      _required
    )
    daylimit(
      _daylimit
    )
  {}

  // DEFAULT METHOD
  // ——————————————
  // gets called when no other function matches
  function()
    payable
  {
    // just being sent some cash?
    if (msg.value > 0) {
      Deposit(msg.sender, msg.value);
    }
  }

  // Outside-visible transact entry point.
  // —————————————————————————————————————
  // Executes transaction immediately if below daily spend limit.
  // If not, goes into multisig process:
  // We provide a hash on return to allow the sender to provide
  // shortcuts for the other confirmations
  // (to avoid duplicating the _to, _value and _data arguments).
  // They still get the option of using them if they want, anyways.
  function execute(
    address _to,
    uint    _value,
    bytes   _data
  )
    external
    onlyowner
    returns (bytes32 _r)
  {

    // first, check that we're under the daily limit.
    if (underLimit(_value)) {
      SingleTransact(msg.sender, _value, _to, _data);
      // yes - just execute the call.
      if (!_to.call.value(_value)(_data)) throw;
      return 0;
    }

    // determine our operation hash.
    _r = sha3(msg.data, block.number);

    if (!confirm(_r) && m_txs[_r].to == 0) {
      m_txs[_r].to    = _to;
      m_txs[_r].value = _value;
      m_txs[_r].data  = _data;

      ConfirmationNeeded(
        _r,
        msg.sender,
        _value,
        _to,
        _data
      );
    }
  }

  // Confirm a transaction through just the hash.
  // ————————————————————————————————————————————
  // We use the previous transactions map, m_txs, in order to
  // determine the body of the transaction from the hash provided.
  function confirm(
    bytes32 _h
  )
    onlymanyowners(_h)
    returns (bool)
  {
    if (m_txs[_h].to != 0) {
      if (!m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data)) throw;

      MultiTransact(
        msg.sender,
        _h, m_txs[_h].value,
        m_txs[_h].to,
        m_txs[_h].data
      );

      delete m_txs[_h];

      return true;
    }
  }

  // INTERNAL METHODS

  function clearPending()
    internal
  {
    uint length = m_pendingIndex.length;

    for (uint i = 0; i < length; ++i)
      delete m_txs[m_pendingIndex[i]];

    super.clearPending();
  }
}
