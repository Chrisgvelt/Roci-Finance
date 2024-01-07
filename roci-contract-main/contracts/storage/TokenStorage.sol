pragma solidity ^0.4.18;

contract TokenStorage {

    // URIs array stored against token IDs;
    mapping(uint256 => string) private _tokenURIs;
    // Address array stored against token IDs; addresses bundled with the token
    mapping(uint256 => address[]) private _tokenBundle;
    // Bool stored against tokenId; whether a bundle has been stored in the token or not
    mapping (uint256 => bool) private _bundleNonce;

    /**** Get Methods ***********/

    function getTokenURI(uint256 tokenID) public view returns (string) {
        return _tokenURIs[tokenID];
    }

    function getTokenBundle(uint256 tokenID) public view returns (address[]) {
        return _tokenBundle[tokenID];
    }

    function getBundleNonce(uint256 tokenID) public view returns (bool) {
        return _bundleNonce[tokenID];
    }

    /**** Set Methods ***********/

    function setTokenURI(uint256 tokenID, string URI) public {
        _tokenURIs[tokenID] = URI;
    }

    function setTokenBundle(uint256 tokenID, address[] bundle) public {
        _tokenBundle[tokenID] = bundle;
    }

    function setBundleNonce(uint256 tokenID, bool nonce) public {
        _bundleNonce[tokenID] = nonce;
    }

    /**** Delete Methods ***********/

    function deleteTokenURI(uint256 tokenID) public {
        delete _tokenURIs[tokenID];
    }

    function deleteTokenBundle(uint256 tokenID) public {
        delete _tokenBundle[tokenID];
    }

    function deleteBundleNonce(uint256 tokenID) public {
        delete _bundleNonce[tokenID];
    }

}