// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// TokenBar is the coolest bar in town. You come in with some Token, and leave with more! The longer you stay, the more Token you get.
//
// This contract handles swapping to and from xToken, the staking token.
contract TokenBar is ERC20{
    IERC20 public token;

    // Define the Token token contract
    constructor(address _token) ERC20("Roci DAI", "rDAI"){
        token = IERC20(_token);
    }

    // Enter the bar. Pay some TOKENs. Earn some shares.
    // Locks Token and mints xToken
    function _enter(uint256 _amount, address _entering) internal {
        // Gets the amount of Token locked in the contract
        uint256 totalToken = token.balanceOf(address(this));
        // Gets the amount of xToken in existence
        uint256 totalShares = totalSupply();
        // If no xToken exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalToken == 0) {
            _mint(_entering, _amount);
        }
        // Calculate and mint the amount of xToken the Token is worth. The ratio will change overtime, as xToken is burned/minted and Token deposited + gained from fees / withdrawn.
        else {
            uint256 what = (_amount * totalShares) / (totalToken);
            _mint(_entering, what);
        }
        // Lock the Token in the contract
        token.transferFrom(_entering, address(this), _amount);
    }

    // Leave the bar. Claim back your TOKENs.
    // Unlocks the staked + gained Token and burns xToken
    function _leave(uint256 _share) internal {
        // Gets the amount of xToken in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Token the xToken is worth
        uint256 what = (_share * token.balanceOf(address(this))) / (totalShares);
        _burn(msg.sender, _share);
        token.transfer(msg.sender, what);
    }

}
