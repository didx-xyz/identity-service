pragma solidity ^0.4.9;

contract Restricted_Wallet {
  address public r_admin;
  address public r_registry;

  modifier onlyadmin {
    if (msg.sender != r_admin) throw;
    _;
  }

  modifier notrestricted(address _to) {
    if (_to == r_registry && msg.sender != r_admin) throw;
    _;
  }

  // CONSTRUCTOR
  // ———————————
  function Restricted_Wallet(
    address administrator,
    address registry_addr
  ) {
    r_admin = administrator;
    r_registry = registry_addr;
  }
}
