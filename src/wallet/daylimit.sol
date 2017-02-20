pragma solidity ^0.4.9;

import "wallet/multiowned.sol";

// Inheritable "property" contract that enables methods to be protected
// by placing a linear limit (specifiable) on a particular resource
// per calendar day. Is `multiowned` to allow the limit to be altered.
// resource that method uses is specified in the modifier.
contract daylimit is multiowned {

  uint public m_dailyLimit;
  uint public m_spentToday;
  uint public m_lastDay;

  // simple modifier for daily limit.
  modifier limitedDaily(uint _value) {
    if (underLimit(_value))
      _;
  }

  // CONSTRUCTOR
  // ———————————
  // stores initial daily limit and records the present day's index.
  function daylimit(uint _limit) {
    m_dailyLimit = _limit;
    m_lastDay = today();
  }

  // (re)sets the daily limit.
  // needs many of the owners to confirm.
  // doesn't alter the amount already spent today.
  function setDailyLimit(uint _newLimit)
    onlymanyowners(sha3(msg.data))
    external
  {
      m_dailyLimit = _newLimit;
  }

  // resets the amount already spent today.
  // needs many of the owners to confirm.
  function resetSpentToday()
    onlymanyowners(sha3(msg.data))
    external
  {
    m_spentToday = 0;
  }

  // INTERNAL METHODS
  // ————————————————

  // Checks to see if there is at least `_value` left from the daily
  // limit today. If there is, subtracts it and returns true,
  // otherwise just returns false.
  function underLimit(uint _value)
    internal
    onlyowner
    returns (bool)
  {
    // reset the spend limit if we're on a different day to last time.
    if (today() > m_lastDay) {
      m_spentToday = 0;
      m_lastDay = today();
    }

    // check to see if there's enough left
    // if so, subtract and return true.
    // overflow protection
    // dailyLimit check
    if (
        m_spentToday + _value >= m_spentToday
     && m_spentToday + _value <= m_dailyLimit
    ) {
      m_spentToday += _value;
      return true;
    }

    return false;
  }

  // determines today's index.
  function today()
    private
    constant
    returns (uint)
  {
    return now / 1 days;
  }
}
