// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on a local anvil chain, we will deploy mocks
    //If we are on a testnet, we will use the existing price feed address from the live network

    struct NetworkConfig {
        address priceFeed; //EthUSd price feed address
    }

    NetworkConfig public activeNetworkConfig; //This is the config we will use to deploy our contract

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; //2000 USD

    constructor() {
        if (block.chainid == 11155111) {
            //Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        }

        if (activeNetworkConfig.priceFeed == address(0)) {
            //Anvil or local network
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //retunr config for sepolia
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        //return config for anvil
        //Deploy the mocks and retrun the mocck address

        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; //If we have already deployed the mocks, return the address
        }
        vm.startBroadcast();

        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(
            address(mockV3Aggregator)
        );
        return anvilConfig;
    }
}
