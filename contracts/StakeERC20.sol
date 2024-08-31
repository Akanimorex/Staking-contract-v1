// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//single stake for user


contract StakeERC20 {
    address owner ;
    IERC20 public token;
    uint256 rewardBalance =token.balanceOf(msg.sender); 
    
    constructor(address _token) payable{
        owner = msg.sender;
        require(msg.value >0,"Must be greater than zero");
        token =IERC20(_token);
    }
   

    struct Stakes {
        address account;
        uint256 unlockTime;
        uint256 stakedBalance;
        bool isComplete;
    }

   

    mapping(address => Stakes) stakes;



    modifier onlyOwner(){
        require(msg.sender == owner , "not dev, can't do this");
        _;
    }



    function stake(uint256  _days, uint256 _amount) external payable{
        //sanity check
        require(msg.sender != address(0),"zero address detected");
        // require(msg.value > 0,"balance too low"); do the erc-20 
        require(_days > 0,"invalid date");
        require(rewardBalance > 0, "You cannot stake for now, No reward epoch");

        token.transferFrom(msg.sender, address(this), _amount);

        uint256 _unlockTime = block.timestamp + (_days/86400);
        //msg.value + interest somewhere  = reward
        Stakes memory  sd;
        sd.unlockTime = _unlockTime; 
        sd.stakedBalance = _amount;   
        stakes[msg.sender]=sd;
    }

  
    function withdraw()external {
        //sanity check
        require(msg.sender != address(0),"zero address");
        require(stakes[msg.sender].unlockTime <= block.timestamp,"Staking is still ongoing");
        require(stakes[msg.sender].stakedBalance > 0, "zero balance");


        Stakes storage account = stakes[msg.sender];

       //update the complete staking checker
        account.isComplete = true;

        uint256 diff = block.timestamp - account.unlockTime;

        uint256 reward = (account.stakedBalance * 1* diff * 1*10**18) / 100;

        rewardBalance -= reward;
        account.isComplete = false;
        account.stakedBalance =0;
        account.unlockTime = 0;

        token.transfer(msg.sender, (account.stakedBalance + reward));


        // check if timer has elapsed

    }

   function getUserStake() public view returns(uint256) {
         return(stakes[msg.sender].stakedBalance);

   }


   



}



