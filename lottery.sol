// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery{

    address payable public manager;
    address payable[] public participants;
    struct Manager {
        uint rand;
    }

    Manager oracle; // just to make a little more independent from manipulating the block.timestamp by bad actors.

    constructor() {
        uint i = participants.length;
        manager = payable(msg.sender);
        oracle = Manager(i);
    }

     modifier onlyBy() {
        require(msg.sender == manager);
        _;
    }

    /*receive() payable external {
        require (msg.value >= 1 ether && msg.value % 1 == 0, "Your payment should be multiple of 1 Ether");
        uint count = msg.value;
        uint r = count % 1;
        for (uint i = 1; i <= r; i++){
            participants.push(payable(msg.sender));
        }
    }*/
    
    // I tried this above given receive() function , but it didn't work as intended... But i am working on improving it.

    receive() payable external {
        require (msg.value == 1 ether, "Your payment should be equal to 1 Ether");
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require (msg.sender == manager);
        return address(this).balance;
    }

    function getWinner() public onlyBy() returns (uint rand){
        require(participants.length >= 3);
        address payable winner;
        rand = uint (keccak256(abi.encodePacked(oracle.rand, block.difficulty, block.timestamp, participants.length))) % participants.length;
        winner = participants[rand];
        winner.transfer(getBalance()*9/10); 
        manager.transfer(getBalance()*1/10);
        participants = new address payable[](0);
    }
}
