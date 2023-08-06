//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract A{
    address public owner_a;
    constructor(address eoa) {
        owner_a = eoa;
    }
}

contract Creator{

    address public ownercreator;
    A[] public deployedA;

    constructor(){
        ownercreator = msg.sender;
    }

    function deployA() public {
        A new_a_address = new A(msg.sender);
        deployedA.push(new_a_address);
    }
}