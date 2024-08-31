// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//single stake for user


contract staking {
    address owner ;
    uint256 contractBalance;
   
    constructor() payable{
        owner = msg.sender;
        require(msg.value >0,"Must be greater than zero");
    }

    struct Stakes {
        address account;
        uint256 unlockTime;
        uint256 stakedBalance;
        uint256 expectedInterest;
        bool isComplete;
        // uint256 rewardBalance;
    }

    // mapping(address => uint) stakes;

    mapping(address => Stakes) stakes;




    modifier onlyOwner(){
        require(msg.sender == owner , "not dev, can't do this");
        _;
    }



    function stake(uint256  _days) external payable{
        require(msg.value > 0,"balance too low");

        uint256 _unlockTime = block.timestamp + _days;
        //msg.value + interest somewhere  = reward
        Stakes memory  sd;
        sd.unlockTime = _unlockTime; 
        sd.stakedBalance = msg.value;   
        stakes[msg.sender]=sd;
    }

    function withdraw()external payable{
        //sanity check
        require(msg.sender != address(0),"zero address");
        // require(_amount > 0, "you can't withdraw zero balance");
        require(stakes[msg.sender].unlockTime <= block.timestamp,"Staking is still ongoing");

         Stakes storage account = stakes[msg.sender];

       //update the complete staking checker
        account.isComplete = true;

        uint256 diff = block.timestamp - account.unlockTime;

        uint256 reward = (account.stakedBalance * 1* diff * 1*10**18) / 100;

        (bool success,) = msg.sender.call{value:msg.value + reward}("");

        require(success,"failed to unstake and withdraw");

        //check if timer has elapsed

    }

   function getUserStake() public view returns(Stakes memory) {
         return(stakes[msg.sender]);

   }


}



