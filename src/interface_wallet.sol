pragma solidity ^0.4.9;

contract wallet_interface {
  function isOwner(address sender) returns (bool);
  function isAdmin(address sender) returns (bool);
}
