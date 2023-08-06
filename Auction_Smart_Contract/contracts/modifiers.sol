//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// function modifiers are used to test a code's condition befopre calling
// and will only execute if it evaluates to true
// the do not return anyn value and use require()

contract Property{

    uint public price;
    address public owner;

    constructor(){
        price=0;
        owner = msg.sender;

    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function changeOwner(address _owner) public onlyOwner{
        owner = _owner;
    }

    function setPrice(uint _price) public onlyOwner{
        price = _price;
    }
}