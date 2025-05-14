//Get funds from Users
// withdraw funds
// set a minimum funding value
// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PriceConvertor} from "./PriceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] private s_funders;

    address public immutable owner;

    AggregatorV3Interface public s_priceFeed;

    constructor(address priceFeedAddress) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    mapping(address => uint256) private s_addressToAmountFunded;

    function fund() public payable {
        // This function allows users to send money and set a minimum amount they can send
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Not enough ETH sent"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[
            msg.sender
        ] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        uint256 fundID = 0;
        for (fundID; fundID < fundersLength; fundID++) {
            address fundersIndex = s_funders[fundID];
            s_addressToAmountFunded[fundersIndex] = 0;
            address funder = fundersIndex;
            s_addressToAmountFunded[funder] = 0;
            (bool sendSuccess, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            require(sendSuccess, "Send Failed");
        }

        s_funders = new address[](0);
    }

    function withdraw() public onlyOwner {
        uint256 fundID = 0;
        for (fundID; fundID < s_funders.length; fundID++) {
            address fundersIndex = s_funders[fundID];
            s_addressToAmountFunded[fundersIndex] = 0;
            address funder = fundersIndex;
            s_addressToAmountFunded[funder] = 0;
            (bool sendSuccess, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            require(sendSuccess, "Send Failed");
        }

        s_funders = new address[](0); //This is to reset the array after all the senders have been refunded
    }

    function getVersion() public view returns (uint256) {
        // This function converts the amount of ETH to USD
        // (, int256 price, , , ) = s_priceFeed.latestRoundData();
        // return uint256(price) * 1e10;
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner, "Only contract owner can withdraw");
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}
