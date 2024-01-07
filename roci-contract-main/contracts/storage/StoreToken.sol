pragma solidity ^0.4.0;
import "./TokenStorage.sol";
import './StorageConsumer.sol';
import '../proxy/Proxy.sol';

contract StoreToken is StorageConsumer, Proxy {
    function StoreToken(TokenStorage storage_)
    public
    StorageConsumer(storage_)
    {
    }
}