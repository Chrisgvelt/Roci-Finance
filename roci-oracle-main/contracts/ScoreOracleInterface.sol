//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ScoreOracleInterface {
  function getLatestScore(uint256 tokenId) external returns (uint256);
}
