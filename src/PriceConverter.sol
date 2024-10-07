// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeedContract
    ) public returns (uint256) {
        (, int256 answer, , , ) = priceFeedContract.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(
        uint256 ammountETH,
        AggregatorV3Interface priceFeedContract
    ) public returns (uint256) {
        uint256 priceOfEth = getPrice(priceFeedContract);

        return (ammountETH * priceOfEth) / 1e18;
    }

    function getVersion(
        AggregatorV3Interface priceFeedContract
    ) public returns (uint256) {
        return priceFeedContract.version();
    }
}
