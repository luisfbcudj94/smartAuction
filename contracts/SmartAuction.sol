// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

contract SmartAuction{

    address public beneficiary;
    uint public auctionEnd;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime) public {
        beneficiary = msg.sender;
        auctionEnd = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        require(block.timestamp <= auctionEnd, "Auction already over.");
        require(msg.value > highestBid, "There is already a higher bid.");

        if(highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool){
        uint amount = pendingReturns[msg.sender];

        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            if(!payable(msg.sender).send(amount)){ 
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }

        return true;
    }

    function auctionEndFunction() public {
        require(block.timestamp >= auctionEnd,"Auction not yet ended.");
        require(!ended,"AuctionEnd was called.");

        ended = true;

        payable(beneficiary).transfer(highestBid);

        emit AuctionEnded(highestBidder, highestBid);
    }

    function auctionAlreadyEnded() public view returns (bool){
        return ended;
    }
}