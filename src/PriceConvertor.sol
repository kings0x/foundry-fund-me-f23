// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // this funciton allows the user to view the current price of ETH in USD
        uint256 ethPrice = getPrice(priceFeed);
        uint256 minimumValue = (ethPrice * ethAmount) / 1e18;
        return minimumValue;
    }

    function getPrice(
        AggregatorV3Interface pricefeed
    ) internal view returns (uint256) {
        // This function converts the amount of ETH to USD

        (, int256 price, , , ) = pricefeed.latestRoundData();
        return uint256(price) * 1e10;
    }
}
