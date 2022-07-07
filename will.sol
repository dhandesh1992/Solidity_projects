//SPDX-License-Identifier: Unlicensed
pragma solidity >0.5.7;

contract Will {
    address owner; // The Grandfather who is inheriting his fortune to his successors
    uint fortune; // The Money, property, digital currency that the owner has in his possession
    bool deceased; // Checks if the owner is alive or dead.
    address payable [] public familyWallets;
    
    mapping (address => uint) public inheretance;

    constructor() payable {
        owner = msg.sender;
        fortune = msg.value;
        deceased = false;    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the Owner");
        _;
    }

    modifier mustBeDeceased() {
        require(deceased == true, "The Sweet Grandfater is Happy and Alive");
        _;
    }

    function setInheretance(address payable wallet, uint amount) public onlyOwner{
        familyWallets.push(wallet);
        inheretance[wallet] = amount * 1 ether;
    }

    function getInheretance(address payable wallet) public view returns(uint) {
        return inheretance[wallet];
    }
    
    function payOut() private mustBeDeceased {
        for (uint i = 0; i<familyWallets.length ; i++) {
            familyWallets[i].transfer(inheretance[familyWallets[i]]);
        }
    }

    function refreshContract() private mustBeDeceased {
        familyWallets = new address payable[](0); // this is just to keep in check that the contract is not being used multiple times.
    }

    function hasDeceased() public onlyOwner{
        deceased = true;
        payOut(); // triggering payOut() function through the hasDeceased() function as it is put in private visibility
        refreshContract(); // triggering refreshContract() function through the hasDeceased() function as it is put in private visibility
    }
}
