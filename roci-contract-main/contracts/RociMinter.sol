//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

/// @notice NOT PRODUCTION READY

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./storage/StorageStateful.sol";

contract RociMinter is ERC721, Ownable, StorageStateful {
    // This means that the uint256 type can call functions in the Strings library
    // And Counters.Counter type can call those in Counters library
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor(string memory tokenName, string memory symbol) ERC721 (tokenName, symbol) {}

    function mintToken(address recipient, address[] memory bundle) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _safeMint(recipient, id);
        //Now, store the bundle against the token Id
        require(!_storage.getBundleNonce(id), "This token already has an associated bundle");
        storeBundle(id, bundle);
        return id;
    }

    function setTokenURI (uint256 tokenId, string memory _tokenURI) public onlyOwner {
        require(_exists(tokenId), "ERC721: cannot set URI of nonexistent token");
        _storage.setTokenURI(tokenId, _tokenURI);
    }

    function generateTokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: cannot get URI of nonexistent token");
        string memory _tokenURI = _storage.getTokenURI(tokenId);
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId);
    }

    function _baseURI () override internal pure returns (string memory) {
        return "ipfs://";
    }

    function convertToString(uint256 bigNumber) public pure returns (string memory) {
       return bigNumber.toString();
    }

    function transferToken(address from, address to, uint256 tokenId) public onlyOwner {
        _safeTransfer(from, to, tokenId, "");
        emit Transfer(from, to, tokenId);
    }

    function storeBundle (uint256 tokenId, address[] memory bundle) public {
        require(_exists(tokenId), "ERC721: cannot store bundle for nonexistent token");
        require(!_storage.getBundleNonce(tokenId), "This token already has an associated bundle");
        // Store the address bundle against tokenId
        _storage.setTokenBundle(tokenId, bundle);
        // Set the bundle status as true
        _storage.setBundleNonce(tokenId, true);
    }

// Create and return an array
    function getBundle(uint256 tokenId) public view returns (address[] memory) {
        require(_exists(tokenId), "ERC721: cannot get bundle of nonexistent token");
        require(_storage.getBundleNonce(tokenId), "This token does not have an associated address bundle yet");
        // Return array of addresses
    
        address[] memory tokenBundle = _storage.getTokenBundle(tokenId);
        address[] memory bundle = new address[](tokenBundle.length);
        for (uint i = 0; i < tokenBundle.length; i++) {
            bundle[i] = tokenBundle[i];
        }
        return bundle;
    }

    function getBundle2(uint256 tokenId) public view returns (address[] memory) {
        require(_exists(tokenId), "ERC721: cannot get bundle of nonexistent token");
        require(_storage.getBundleNonce(tokenId), "This token does not have an associated address bundle yet");
        return _storage.getTokenBundle(tokenId);
    }

}
