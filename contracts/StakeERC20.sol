// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakeERC20 {
    address public owner;
    IERC20 public token;
    uint256 public rewardBalance; // Removed initialization here

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        rewardBalance = token.balanceOf(msg.sender); // Initialize in constructor
    }

    struct Stakes {
        address account;
        uint256 unlockTime;
        uint256 stakedBalance;
        bool isComplete;
    }

    mapping(address => Stakes) public stakes;

    modifier onlyOwner() {
        require(msg.sender == owner, "not dev, can't do this");
        _;
    }

    function stake(uint256 _days, uint256 _amount) external {
        // Sanity checks
        require(msg.sender != address(0), "zero address detected");
        require(_days > 0, "invalid date");
        require(rewardBalance > 0, "You cannot stake for now, No reward epoch");

        // Transfer tokens from the staker to the contract
        token.transferFrom(msg.sender, address(this), _amount);

        // Calculate unlock time (convert days to seconds)
        uint256 _unlockTime = block.timestamp + (_days * 86400);

        // Create the stake
        Stakes memory sd;
        sd.account = msg.sender;
        sd.unlockTime = _unlockTime;
        sd.stakedBalance = _amount;
        sd.isComplete = false;
        stakes[msg.sender] = sd;
    }

    function withdraw() external {
        // Sanity checks
        require(msg.sender != address(0), "zero address");
        Stakes storage account = stakes[msg.sender];
        require(account.unlockTime <= block.timestamp, "Staking is still ongoing");
        require(account.stakedBalance > 0, "zero balance");
        require(!account.isComplete, "Stake already withdrawn");

        // Calculate reward (simple example, you can adjust the formula)
        uint256 reward = (account.stakedBalance * 10) / 100; // 10% reward for example

        // Update the contract's state
        account.isComplete = true;
        rewardBalance -= reward;

        // Transfer staked tokens + reward to the user
        uint256 payout = account.stakedBalance + reward;
        account.stakedBalance = 0;
        token.transfer(msg.sender, payout);
    }

    function getUserStake() public view returns (uint256) {
        return stakes[msg.sender].stakedBalance;
    }
}
