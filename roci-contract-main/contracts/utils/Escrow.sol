pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Escrow {
    uint256 public escrowTime; // escrow pending time

    constructor(uint256 _escrowTime) public {
        escrowTime = _escrowTime;
    }

    mapping(address => mapping(address => uint256)) public escrowBalance;       // escrowed balance per user for each token
    mapping(address => mapping(address => uint256)) public escrowExpiration;    // escrow expiration delay per user for each token

    function deposit(IERC721Token token, uint256 tokenId) public {              // deposit into escrow contract from sender
        require(token.transferFrom(msg.sender, this, tokenId));
        escrowBalance[msg.sender][token] += token.balanceOf(msg.sender);
        escrowExpiration[msg.sender][token] = 2**256-1;
    }

    event StartWithdrawal(address indexed account, address token, uint256 time);

    function startWithdrawal(IERC721Token token) public {                       // withdraw starting point as a event
        uint256 expiration = now + escrowTime;
        escrowExpiration[msg.sender][token] = expiration;
        emit StartWithdrawal(msg.sender, token, expiration);
    }

    function withdraw(IERC721Token token, uint256 tokenId) public {             // withdraw to sender from escrow contract after escrow pending
        require(now > escrowExpiration[msg.sender][token],
            "Funds still in escrow.");

        uint256 amount = escrowBalance[msg.sender][token];
        escrowBalance[msg.sender][token] = 0;
        require(token.transferFrom(msg.sender, amount, tokenId));
    }

    function transferToken(                                                     // transfer token via escrow contract
        address from,
        address to,
        IERC721Token token,
        uint256 tokenId
    )
        internal
    {
        require(escrowBalance[from][token] >= token.balanceOf(from), "Insufficient balance.");

        escrowBalance[from][token] -= token.balanceOf(from);
        escrowBalance[to][token] += token.balanceOf(from);
    }
}