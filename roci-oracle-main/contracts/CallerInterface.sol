//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface CallerContractInterface {
  function callback(uint16 _score, uint256 tokenId, uint256 id) external;
}