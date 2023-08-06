//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract AuctionCreator{
    Auction[] public auctions;

    function createAuction() public{
        Auction newAuction = new Auction(msg.sender);
        auctions.push(newAuctiom);
    }
}

contract Auction{

    address payable public owner;
    uint public start_block;
    uint public end_block;
    string public ipfshash;

    enum State {Started, Running, Ended, Canceled}
    State public auctionstate;

    uint public highestbindingbid;
    address payable public highestbidder;

    mapping(address => uint) public bids;
    uint bidincrement;

    constructor(address eoa){
        owner = payable(eoa));
        auctionstate = State.Running;
        start_block = block.number;
        //(60*60*24*7)/15 to get the number of blocks generated in a week as 2018
        end_block = start_block + 40320; 
        ipfshash = "";
        bidincrement = 100;
    }

    // the modifiers are set to hinder the owner from tampering with the algoritm
    // once the auction begins
    modifier notOwnwer(){
        require(msg.sender != owner);
        _;
    }

    modifier afterStart(){
        require(block.number >= start_block);
        _;
    }

    modifier beforeEnd(){
        require(block.number <= end_block);
        _;
    }

    //helper function to find minimum of two numbers
    function min(uint a, uint b) pure internal returns(uint){
        if (a <= b){
            return a;
        }
        else{
            return b;
        }
    }

    function placeBid() public payable notOwnwer afterStart beforeEnd {
        require(auctionstate == State.Running);
        require(msg.value >= 100);

        uint currentbid = bids[msg.sender] + msg.value;
        require(currentbid>highestbindingbid);

        bids[msg.sender] = currentbid;
        if(currentbid <= bids[highestbidder]){
            highestbindingbid = min(currentbid+bidincrement, bids[highestbidder]);
        }
        else{
            highestbindingbid = min(currentbid, bids[highestbidder] + bidincrement);
            highestbidder = payable(msg.sender);
        }
    }

    //owner is not allowed to place bid
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    // in case of a detected vulnberalbility or issue to cancel the auction
    function cancelAuction() public onlyOwner{
        auctionstate = State.Canceled;
    }

    function finalizeAuction() public {
        require(auctionstate == State.Canceled || block.number > end_block);
        require(msg.sender ==owner || bids[msg.sender] > 0);

        address payable recepient;
        uint value;
        
        //if auction is cancelled
        if (auctionstate == State.Canceled){
            recepient = payable(msg.sender);
            value = bids[msg.sender];
        }
        // if auction ended
        else{
            if(msg.sender == owner){ //owner
                recepient = owner;
                value = highestbindingbid;
            }
            else{ //bidder
                if (msg.sender == highestbidder){
                    recepient = highestbidder;
                    value = bids[highestbidder] - highestbindingbid;
                }
                else{ //neither owner nor highest bidder
                    recepient = payable(msg.sender);
                    value = bids[msg.sender];
                } 
            }

        }
        //reset bidders list to avoid multiple requests
        bids[recepient] = 0;
        //send back bid value to registered bidders
        recepient.transfer(value);
    }
}