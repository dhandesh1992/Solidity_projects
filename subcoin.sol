// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.5.0 <0.9.0;

contract Guna {
    // The public visibility makes the variable accessible by other contracts...
    address public minter;
    uint public totalcoins = 0;
    mapping (address => uint) public balances;
    event Minted (address minter, uint amount);
    event Sent (address from, address to, uint amount);

    constructor() {
        minter = msg.sender;
    }

    // Make new coins and send them to an address
    // only the minter can mint the coins...

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        balances[receiver] += amount;
        totalcoins += amount;
        emit Minted (minter, amount);
    }

    error insufficientBalance(uint requested, uint available);

    function send(address receiver, uint amount) public{
        if(amount > balances[msg.sender]){
        revert insufficientBalance ({
            requested: amount,
            available: balances[msg.sender]
        });
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
        }
    }
    
    function destroyCoin(address _addr) public payable {
        require(msg.sender == minter);
        require(block.timestamp >= 730 days);
        selfdestruct(payable(_addr));
    }
}
