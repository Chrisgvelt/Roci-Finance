//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./CallerInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Receives requests to fetch scores fork given token IDs

contract ScoreOracle is Ownable{
  // Data needed for request id calculation  
  // In future could use Chainlink VRF
  uint private randNonce = 0;
  uint private modulus = 1000;
  // New id for each Score request is generated and put here
  mapping(uint256=>bool) private pendingRequests; 
  // events for getting and setting latest Score
  event GetLatestScore(address callerAddress, uint tokenId, uint requestId);
  event SetLatestScore(uint16 score, uint tokenId, address callerAddress);

  // Calculates new ID for each request, sets its pending status to true, emits an event with caller address and id so NodeJS process can intercept and return the new Score
  function getLatestScore(uint256 tokenId) public returns (uint256) {
    // Generate new requestId
    randNonce++;
    uint requestId = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % modulus;
    // Set RequestId processing status to true
    pendingRequests[requestId] = true;
    // Emit event with caller address, tokenId and requestId
    emit GetLatestScore(msg.sender, tokenId, requestId);
    // Since oracle cannot return score immediately as the outside oracle service has to detect event and call setLatestScore func to send the score for the respective tokenId, 
    // We return the request Id to the caller contract
    return requestId;
  }

  // Called by the NodeJS process when it returns the lates  Score along with caller address and his ID (NodeJS process private key is the owner)
  function setLatestScore(uint16 _score, address _callerAddress, uint _tokenId,  uint256 _id) public onlyOwner {
    // Require that that request actually exists and is pending
    require(pendingRequests[_id], "Request not in pending list.");
    // Remove the request since its fulfilled now    
    delete pendingRequests[_id];
    // Call the callback func of caller contract with the Score, request Id and token Id
    CallerContractInterface callerContractInstance;
    callerContractInstance = CallerContractInterface(_callerAddress);
    callerContractInstance.callback(_score, _tokenId, _id);
    // Emit Score update event to let frontend know that a new  Score has been set
    emit SetLatestScore(_score, _tokenId, _callerAddress);
  }
}

