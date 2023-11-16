// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./Token.sol";

contract MyTokenSale {


    MyToken public myToken; // Custom MyToken contract being sold
    uint256 public tokenPrice; // Initial price of each token in Ether
    uint256 public rate; // Rate of tokens per Ether
    uint256 public crowdsaleStartTime; // Start time of the crowdsale
    uint256 public crowdsaleEndTime; // End time of the crowdsale
    bool public crowdsaleActive; // Flag to indicate whether the crowdsale is active or not

    mapping(address => uint256) public tokensPurchased; // Track the number of tokens purchased by each address
    uint256 public totalEtherRaised; // Total Ether raised in the crowdsale
    uint256 public totalTokensSold; // Total tokens sold in the crowdsale

    event TokensPurchased(address indexed buyer, uint256 etherAmount, uint256 tokenAmount);

    modifier onlyDuringCrowdsale() {
        require(
            crowdsaleActive && block.timestamp >= crowdsaleStartTime && block.timestamp <= crowdsaleEndTime,
            "Crowdsale is not active or outside of the valid period"
        );
        _;
    }

    constructor(
        MyToken _myToken,
        uint256 _tokenPrice,
        uint256 _rate,
        uint256 _crowdsaleStartTime,
        uint256 _crowdsaleEndTime
    ) {
        myToken = _myToken;
        tokenPrice = _tokenPrice;
        rate = _rate;
        crowdsaleStartTime = _crowdsaleStartTime;
        crowdsaleEndTime = _crowdsaleEndTime;
        crowdsaleActive = false;
    }

    function startCrowdsale() external {
        require(!crowdsaleActive, "Crowdsale is already active");
        crowdsaleActive = true;
    }

    function stopCrowdsale() external {
        require(crowdsaleActive, "Crowdsale is not active");
        crowdsaleActive = false;
    }

    function updateTokenPrice(uint256 newTokenPrice) external {
        require(newTokenPrice > 0, "Token price must be greater than zero");
        tokenPrice = newTokenPrice;
    }

    function purchaseTokens() external payable onlyDuringCrowdsale {
        require(msg.value > 0, "Ether amount should be greater than zero");

        uint256 tokenAmount = msg.value*(rate); // Calculate the number of tokens based on the rate
        require(tokenAmount <= myToken.balanceOf(address(this)), "Not enough tokens available for sale");

        myToken.transfer(msg.sender, tokenAmount); // Transfer tokens to the buyer
        tokensPurchased[msg.sender]+=(tokenAmount); // Record the purchase

        totalEtherRaised += (msg.value); // Update total Ether raised
        totalTokensSold += (tokenAmount); // Update total tokens sold

        emit TokensPurchased(msg.sender, msg.value, tokenAmount); // Emit an event to log the purchase
    }

    function withdrawFunds() external {
        require(address(this).balance > 0, "No funds to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }

    function distributeTokens(address[] calldata buyers, uint256[] calldata amounts) external {
        require(!crowdsaleActive && block.timestamp > crowdsaleEndTime, "Crowdsale must be stopped");

        require(buyers.length == amounts.length, "Arrays length mismatch");

        for (uint256 i = 0; i < buyers.length; i++) {
            address buyer = buyers[i];
            uint256 tokens = amounts[i];
            myToken.transfer(buyer, tokens);
        }
    }
}

