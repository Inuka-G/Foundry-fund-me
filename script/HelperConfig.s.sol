// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant Decimals = 8;
    int public constant InitialAnswer = 2000e8;
    NetworkConfig public activeNetworkconfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkconfig = getSepoloaEthConfig();
        } else {
            activeNetworkconfig = getOrCreateAnvilEthConfig();
        }
        // else if (block.chainid == 137) {
        //     activeNetworkconfig = getAnvilEthConfig();
        // }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoloaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkconfig.priceFeed != address(0)) {
            return activeNetworkconfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPrice = new MockV3Aggregator(
            Decimals,
            InitialAnswer
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPrice)
        });
        return anvilConfig;
    }
}
