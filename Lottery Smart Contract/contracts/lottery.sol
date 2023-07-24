//SPDX-License-Identifier:GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery{

    //declare a dynamic array to store the players' addresses
    //you can only send and receive ether in payable addresses
    address payable[] public players;

    address public manager;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable{
        //ensure received eth is worth 0.1. 1000000000000000000 wei = 0.1 ether
        //the require statement is an alternative for the if statement in solidity
        // ether values without a unit identifier such as (wei,gwei,ether) assumes
        // the passed value is in wei
        require(msg.value == 1000000000000000000);
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager);
        return address(this).balance;
    }

    // random number generator not to be used in real life deployments
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    ///pick random winner
    // function pickWinner() public view returns(address){
    //     // ensure only manager can call this function to choose winner
    //     require(msg.sender == manager);
    //     // make sure we have minimum of 3 players before deciding winner
    //     require(players.length >= 3);

    //     uint r = random();
    //     address payable winner;

    //     uint index = r%players.length;
    //     winner = players[index];
    //     return winner;
    // }

    ///pick random winner, transfer the sum, reset the lottery
    function pickWinner() public{
        // ensure only manager can call this function to choose winner
        require(msg.sender == manager);
        // make sure we have minimum of 3 players before deciding winner
        require(players.length >= 3);

        uint r = random();
        address payable winner;

        uint index = r%players.length;
        // pick the winner from the list
        winner = players[index];
        
        // transfer balance to the winner
        winner.transfer(getBalance());
        // reset the lottery
        players = new address payable[](0);
    }

}