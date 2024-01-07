//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ScoreOracleInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract CallerContract is Ownable {
    // Stores the score of a tokenId
    mapping (uint256 => uint16) private tokenScore;
    // Holds reference of the oracle contract instance
    ScoreOracleInterface private oracleInstance;
    // Holdes the oracle address
    address private oracleAddress;
    // Mapping to keep track of all requests (necessary because async process)
    mapping(uint256=>bool) private scoreRequests;

    // Emitted when oracle address is updated
    event NewOracleAddress(address oracleAddress);
    // Emitted when new request received
    event ReceivedNewRequestId(uint256 id);
    // Emitted when new score is received from oracle and updated
    event ScoreUpdated(uint256 score, uint256 tokenId, uint256 id);

    // Sets the oracle address (e.g., when we deploy a new oracle contract with updated code)
    function setOracleInstanceAddress (address _oracleInstanceAddress) public onlyOwner {
      oracleAddress = _oracleInstanceAddress;
      oracleInstance = ScoreOracleInterface(oracleAddress);
      emit NewOracleAddress(oracleAddress);
    }

    // Fetch the latest score from oracle
    function getScore(uint256 tokenId) public {
      // Call the oracle function to fetch the latest score, which returns a new id to keep track of this request
      // Once oracle gets the new score, it willc all the callback function with the new score and this ID
      uint256 id = oracleInstance.getLatestScore(tokenId);
      // Add the id to myRequests and set its status to true to show that its pending
      scoreRequests[id] = true;
      // emit  to show receipt of new request to fetch score.
      emit ReceivedNewRequestId(id);
    }

    // Called by oracle whenever score is updated per every unique request id; Only the oracle can call this function
    // We get our request id when we call the oracle for the score, then oracle calls us back with the score and the request id (has to match)
    function callback(uint16 _score, uint256 _tokenId, uint256 _id) public onlyOracle {
      // Check if the request Id given to us by the oracle in updateScore matches with the one we are receiving
      require(scoreRequests[_id], "Request not in pending list.");
      tokenScore[_tokenId] = _score;
      delete scoreRequests[_id];
      emit ScoreUpdated(_score, _tokenId, _id);
    }

    modifier onlyOracle() {
      require(msg.sender == oracleAddress, "Not authorized.");
      _;
    }
}
