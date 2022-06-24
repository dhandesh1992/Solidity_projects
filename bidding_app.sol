// SPDX-License-Identifier: Unlicensed
pragma solidity >0.5.0 <=0.9.0;

contract Auction {
    address payable beneficiary;
    address public highestBidder;
    address payable withdrawer;
    uint public highestBid;
    uint public auctionEndTime;
    uint public buyableAmount;
    mapping (address => uint) public pendingReturns;
    //bool auctionStarted;
    bool ended;

    event WithdrawalTaken (address withdrawer, uint withdrawalAmount);
    event HighestBidIncreased (address highestBidder, uint amount);
    event AuctionEnded (address winner, uint amount);

    constructor (uint _biddingTime, address payable _beneficiary, uint _buyableAmount){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
        buyableAmount = _buyableAmount * 1 ether;
    }

    modifier onlyBy() {
        require (msg.sender == beneficiary);
        _;
    }

    function bid () public payable {
        if (msg.value <= 0.99 ether) {
            revert ("The minimum bid is more than 1 Ethereum");
        }

        if (block.timestamp > auctionEndTime || ended) {
            revert ("The Auction has Ended!");
        }

        if (msg.value <= highestBid) {
            revert ("The Bid is Not High Enough!");
        }

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid; 
        }

        if (msg.sender == highestBidder) {
            revert ("You are already the HighestBidder. Do you want to continue?");
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(highestBidder, highestBid);

        if (msg.value == buyableAmount) {
            ended = true;
            emit AuctionEnded (highestBidder, highestBid);
            beneficiary.transfer(highestBid);
        }
        
    }

    function withdraw() public payable returns(bool){
        msg.sender == withdrawer;
        uint withdrawalAmount = pendingReturns[withdrawer];
        if (highestBid == 0) {
            pendingReturns[withdrawer] = 0;
        }
        if (withdrawalAmount > 0) {
            pendingReturns[withdrawer] = 0;
        }

        if (!payable(withdrawer).send(withdrawalAmount)) {
            pendingReturns[withdrawer] = withdrawalAmount;
        }

        emit WithdrawalTaken (withdrawer, withdrawalAmount);
        return true;
    }

    function buyNow () public payable {
        highestBid = buyableAmount;
        ended = true;
        emit AuctionEnded (highestBidder, highestBid);
        beneficiary.transfer(buyableAmount);
    }

    function auctionEnd() public payable onlyBy {
        require(highestBid != 0);
        if(block.timestamp >= auctionEndTime) {
            ended = true;
        }
        if(ended) revert ("The auction has Ended!");
        ended = true;
        emit AuctionEnded (highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}
