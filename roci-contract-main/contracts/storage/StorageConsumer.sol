pragma solidity ^0.4.18;

import "./TokenStorage.sol";
import "./StorageStateful.sol";

contract StorageConsumer is StorageStateful {
  function StorageConsumer(TokenStorage storage_) public {
    _storage = storage_;
  }
}
