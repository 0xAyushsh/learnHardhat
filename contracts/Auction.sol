// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction{

    //static
    address public immutable owner;
    string public constant productURI = "www.google.com" ;
    uint public endTime ; 
    uint public minBid ;
    uint public highestBid;
    address public highestBidder;
    bool public auctionCancelled;
    mapping(address => uint) public fundsByBidder; 

    constructor(uint numberOfHours,uint _minBid){
        owner = msg.sender;
        minBid = _minBid * 1 ether;
        endTime = block.timestamp + numberOfHours *  1 hours;
        auctionCancelled = false;
    }

    event logHighestBid(address highestBidder , uint highestBid);
    event logAuctionCancelled();
    event LogWithdrawal(address sender, address withdrawalAccount, uint withdrawalAmount);

    error FailedToSendEther();
    error OwnerNotAllowed();
    error OnlyOwnerAllowed();
    error HighestBidderNotAllowed();
    error BidLessThanMinBid();
    error BidLessThanHighest();
    error AuctionHasEnded();
    error AuctionHasCancelled();

    modifier allowedTime(){
        if(block.timestamp > endTime) revert AuctionHasEnded();
        // require(block.timestamp < endTime, " Auction has ended");
        _;
    }

    modifier auctionNotCancelled(){
        if(auctionCancelled) revert AuctionHasCancelled();
        // require(!auctionCancelled, " Auction has been cancelled");
        _;
    }

    modifier onlyOwner(){
        if(msg.sender != owner) revert OnlyOwnerAllowed();
        // require(msg.sender == owner, "Only owner is allowed");
        _;
    }

    modifier notOwner(){
        if(msg.sender == owner) revert OwnerNotAllowed();
        // require(msg.sender != owner, "Owner not allowed ");
        _;
    }


    function bid() public allowedTime auctionNotCancelled notOwner payable returns(bool success){
        uint currentBid = fundsByBidder[msg.sender] + msg.value;
        if(currentBid < minBid) revert BidLessThanMinBid();
        if(currentBid <= highestBid) revert BidLessThanHighest();
        highestBid = currentBid;
        highestBidder = msg.sender;
        fundsByBidder[msg.sender] += msg.value;
        emit logHighestBid(highestBidder , highestBid);
        return true;
    }

    function cancelAuction() onlyOwner allowedTime auctionNotCancelled public returns(bool success){
        auctionCancelled = true;
        emit logAuctionCancelled();
        return true;
    }

    function withdrawFund()  public payable returns(bool success){
        if(!auctionCancelled && (highestBidder == msg.sender)) revert HighestBidderNotAllowed();
        uint withdrawalAmount = 0;
        address withdrawalAccount;
        if(block.timestamp < endTime ){
            if(msg.sender == owner) revert OwnerNotAllowed();
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];
        }else{

            if(msg.sender == owner){    
                withdrawalAccount = highestBidder;
                withdrawalAmount = highestBid;
            }else{
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        if(withdrawalAmount == 0) revert();

        fundsByBidder[withdrawalAccount] = 0;
        (bool sent, ) = withdrawalAccount.call{value: withdrawalAmount}("");
        // require(sent, "Failed to send Ether");
        if(!sent) revert FailedToSendEther();
        emit LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);
        return true;

    }


}