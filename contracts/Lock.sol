// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract staking {
    address owner ;
    uint timer ;

    constructor(){
        owner = msg.sender;
    }

    mapping(address => uint) stakes;

    //oneway  deposit

    function stake(uint256 _amount) external payable{
        require(_amount > 0,"balance too low");
        

    }

    function withdraw(uint256 _amount)external{

    }
}
