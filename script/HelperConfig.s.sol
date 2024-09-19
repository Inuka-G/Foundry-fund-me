// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkconfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkconfig = getSepoloaEthConfig();
        } else {
            activeNetworkconfig = getAnvilEthConfig();
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

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}
