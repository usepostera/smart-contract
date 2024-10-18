// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Postera {
    mapping(address => uint256) private s_wasteEarnings; // User's waste earnings mapping
    mapping(address => uint256) public s_amountFunded;
    mapping(address => bool) public s_userExist; // Checks user existence
    address private immutable i_owner; // Address of Admin
    uint256 public constant MIN_DEPOSIT = 0.1 ether; // Min Deposit Amount

    error not_Owner();

    event WasteEarningUpdated(address indexed user, uint256 newEarning);
    event FundsWithdrawn(address indexed user, uint256 amount);
    event AdminDeposit(address indexed admin, uint256 amount);

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert not_Owner();
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    // Admin Deposit Function.
    function Deposit() public payable onlyOwner {
        require(msg.value >= MIN_DEPOSIT, "You need to send more Eth!");
        s_amountFunded[msg.sender] += msg.value; // Keep track of total deposits
        emit AdminDeposit(msg.sender, msg.value);
    }

    // Function to update waste earnings for a user, only callable by the owner
    function updateWasteEarning(
        address user,
        uint256 earnings
    ) public onlyOwner {
        require(user != address(0), "Invalid address format");

        // Check if the user already exists
        if (!s_userExist[user]) {
            // If the user does not exist, and mark as existing
            s_userExist[user] = true;
        }
        // Update the user's waste earnings
        s_wasteEarnings[user] += earnings;
        emit WasteEarningUpdated(user, s_wasteEarnings[user]);
    }

    // Function for users to withdraw their waste earnings
    function withdraw(uint256 earnings) public {
        require(s_wasteEarnings[msg.sender] > 0, " No earning to Withdraw");

        // Get and reset earnings
        earnings = s_wasteEarnings[msg.sender];
        s_wasteEarnings[msg.sender] = 0;

        // Transfer earnings to user
        (bool success, ) = payable(msg.sender).call{value: earnings}("");
        require(success, "Transfer failed");

        emit FundsWithdrawn(msg.sender, earnings);
    }

    // Getter function to retrieve a user's waste earnings
    function getWasteEarnings(address user) public view returns (uint256) {
        return s_wasteEarnings[user];
    }

    // Getter function to retrieve the contract's balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Fallback and receive functions to handle direct transfers from any other user.
    fallback() external payable {
        Deposit();
    }

    receive() external payable {
        Deposit();
    }
}
