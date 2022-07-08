// SPDX-License-Identifier: Unlicensed
pragma solidity >0.7.0 <=0.9.0;

contract hetero {
    address public minter;
    mapping (address => uint) public balances;
    event Minted (address minter, uint amount);
    event Sent (address from, address to, uint amount);

    constructor() {
        minter = msg.sender;
    }

    modifier onlyBy() {
        require(msg.sender == minter, "You are not the owner of the coin");
        _;
    }

    modifier onlyOnce() {
        require(balances[msg.sender] == 0, "you have already minted"); // We don't want multiple mints
        _;
    }

    function mint(address receiver, uint amount) public onlyBy() onlyOnce() {
        require (receiver == minter, "Please choose your own account"); 
        // We don't want the receiver to be other account, as minter can use this loop 
        // to mint multiple times.
        balances[receiver] += amount;
        emit Minted (minter, amount);
    }

    error insufficientBalance (uint requested, uint amount);

    function send(address receiver, uint amount) public {
        if(balances[msg.sender] >= amount)
        revert insufficientBalance ({
            requested : amount,
            amount    : balances [msg.sender]
        });
        require(msg.sender != receiver, "You can't send coins to yourself");
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent (msg.sender, receiver, amount);
    }

    function destroyCoin(address _addr) public payable onlyBy(){
        require(block.timestamp >= 730 days); 
        // investors should have a guarantee to keep investing atleast for 2 years
        selfdestruct(payable(_addr));
    }
}
