// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

    error AuctionHasBeenStarted();
    error MaxSupplyReached();
    error FailedToSendEther();
    error OwnerNotAllowed();
    error OnlyOwnerAllowed();
    error HighestBidderNotAllowed();
    error BidLessThanMinBid();
    error BidLessThanHighest();
    error AuctionHasEnded();
    error AuctionHasCancelled();
    error MintNFTFirst();
    error AuctionNotStarted();
    


contract AuctionNFT is ERC721 {

    using Strings for uint;
    //static
    bool private auctionStarted = false;



    string private baseURI ;
    // = "https://gateway.pinata.cloud/ipfs/QmQxCPyEJXz3XoWMH1LHGSnaPZVF7TmYaw2SszFFH6jRHC/";// CID of Metadata
    string private constant baseExtension = ".json";
    uint public tokenCounter = 1;
    uint private MAX_SUPPLY = 0;

    address public immutable owner;

    uint public endTime ; 
    uint public minBid ;
    uint public highestBid;
    address public highestBidder;
    bool public auctionCancelled;
    bool private minted = false;
    
    uint private numberOfHours;
    mapping(address => uint) public fundsByBidder; 


    event logHighestBid(address highestBidder , uint highestBid);
    event logAuctionCancelled();
    event LogWithdrawal(address sender, address withdrawalAccount, uint withdrawalAmount);
    event NFTMintedSuccessfully();
    event NFTTransferredSuccessfully();




    modifier onlyOwner() {
        if(msg.sender != owner) revert OnlyOwnerAllowed();
        // require(msg.sender == owner, "Only owner is allowed");
        _;
    }

    modifier onlyAfterNFTMinted(){
        if(!minted) revert MintNFTFirst();
        _;
    }

    modifier onlAfterAuctionStart(){
        if(!auctionStarted) revert AuctionNotStarted();
        _;
    }

    modifier notOwner(){
        if(msg.sender == owner) revert OwnerNotAllowed();
        // require(msg.sender != owner, "Owner not allowed ");
        _;
    }

    modifier allowedTime(){
        if(auctionStarted && block.timestamp > endTime) revert AuctionHasEnded();
        // require(block.timestamp < endTime, " Auction has ended");
        _;
    }

    modifier auctionNotCancelled(){
        if(auctionCancelled) revert AuctionHasCancelled();
        // require(!auctionCancelled, " Auction has been cancelled");
        _;
    }


    constructor(uint _numberOfHours,uint _minBid, string memory nftName, string memory nftSymbol, string memory _baseURI, uint _MAX_SUPPLY) ERC721(nftName, nftSymbol){
        owner = msg.sender;
        baseURI = _baseURI ;
        minBid = _minBid * 1 ether;
        numberOfHours = _numberOfHours;
        auctionCancelled = false;
        MAX_SUPPLY = _MAX_SUPPLY;
    }


    function mintNFT() public onlyOwner payable {
        if(auctionStarted) revert AuctionHasBeenStarted();
        if(tokenCounter > MAX_SUPPLY) revert MaxSupplyReached();
        // msg.sender - who is calling the function
        // tx.origin - this will tell who is one calling the parent transaction full chain
        _safeMint(msg.sender, tokenCounter);
        tokenCounter = tokenCounter + 1;
        // auctionStarted = true;
        emit NFTMintedSuccessfully();
        minted = true;
        // tokenCounter += 1;
     
    }
    

    function startAuction() public onlyOwner onlyAfterNFTMinted returns(bool success){
        if(auctionStarted) revert AuctionHasBeenStarted();
        success = false;
        endTime = block.timestamp + numberOfHours * 1 hours;
        auctionStarted = true;
        success = true; 
    }

    function bid() public onlAfterAuctionStart notOwner allowedTime auctionNotCancelled  payable returns(bool success){
        uint currentBid = fundsByBidder[msg.sender] + msg.value;
        if(currentBid < minBid) revert BidLessThanMinBid();
        if(currentBid <= highestBid) revert BidLessThanHighest();
        highestBid = currentBid;
        highestBidder = msg.sender;
        fundsByBidder[msg.sender] += msg.value;
        emit logHighestBid(highestBidder , highestBid);
        return true;
    }

    function cancelAuction() onlyOwner allowedTime auctionNotCancelled onlAfterAuctionStart public returns(bool success){
        auctionCancelled = true;
        emit logAuctionCancelled();
        return true;
    }

    function withdrawFund()  public payable onlAfterAuctionStart returns(bool success){
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
        if(msg.sender == owner){
            safeTransferFrom(msg.sender, highestBidder , tokenCounter-1);
            emit NFTTransferredSuccessfully();
        }
        return true;
    }

    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
            return bytes(baseURI).length != 0 ?
                string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension)) : "";
        }


}