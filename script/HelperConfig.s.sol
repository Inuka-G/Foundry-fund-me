// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeChainConfig;
    struct NetworkConfig {
        address priceFeedAddress;
    }
    uint8 public constant DECIMAL = 8;
    int public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeChainConfig = getSepoliaConfig();
        } else {
            activeChainConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // deploy mockAggregatorV3
        //check whether mocks are already deployed
        if (activeChainConfig.priceFeedAddress != address(0)) {
            return activeChainConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockAggregator = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        return NetworkConfig({priceFeedAddress: address(mockAggregator)});
    }
}
