// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery{

    address payable public manager;
    bool private locked;
    address payable[] public participants;
    uint public ticketCount;
    address payable winner;
    mapping (address => uint) balances;

    struct Manager {
        uint rand;
    }

    Manager oracle;

    constructor() {
        uint i = participants.length;
        manager = payable(msg.sender);
        oracle = Manager(i);
    }

    modifier onlyBy() {
        require(msg.sender == manager);
        _;
    }

    modifier nonReentrant() {
    require(!locked, "No Reentrancy");
    locked = true;
    _;
    locked = false;
    }

    function Buy() payable external {
        require (msg.value >= 1 ether && msg.value % 1 ether == 0, "No decimals allowed");
        uint val = msg.value / 1 ether;
        for (uint i = 0; i < val; i++){
            participants.push(payable(msg.sender));
        }
        ticketCount += val;
    }

    function getBalance() public view returns(uint) {
        require (msg.sender == manager);
        return address(this).balance;
    }

    function withdrawManagerFunds() private {
        manager.transfer(getBalance());
        ticketCount = 0;
        participants = new address payable[](0);
    }

    function getWinner() public onlyBy() returns (uint rand){
        require(participants.length >= 3);
        rand = uint (keccak256(abi.encodePacked(block.timestamp,msg.sender))) % participants.length;
        winner = participants[rand];
        winner.transfer(getBalance()*9/10);
        withdrawManagerFunds();
    }

    function lastWinner() public view returns(address){
        return winner;
    }
}
