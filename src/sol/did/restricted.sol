pragma solidity ^0.4.9;

contract restricted {
  address public r_admin;
  address public r_registry;

  modifier onlyadmin {
    if (msg.sender != r_admin) throw;
    _;
  }

  modifier notrestricted(address _to) {
    if (_to == r_registry) throw;
    _;
  }

  // CONSTRUCTOR
  // ———————————
  function restricted(
    address administrator,
    address registry_addr
  ) {
    r_admin = administrator;
    r_registry = registry_addr;
  }

  function execute(address _to, uint _value, bytes _data)
    notrestricted(_to)
  {
    super.execute(_to, _value, _data);
  }
}
