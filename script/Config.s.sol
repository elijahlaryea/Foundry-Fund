//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//deploy mocks when on anvil chain
//keep track of contract addresses of different chains
// e.g Sepolia ETH/USD has a different address,
// mainnet ETH/USD has a different address

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public currentNetworkConfig;

    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        //eth/usd price feed address
        address priceFeed;
    }

    constructor() {
        //chain id is unique to every chain
        if (block.chainid == 11155111) {
            currentNetworkConfig = getSepoliaEthConfig();
        } else {
            currentNetworkConfig = getCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaConfig;
    }

    function getCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (currentNetworkConfig.priceFeed != address(0)) {
            return currentNetworkConfig;
        }
        //deploy mock and return mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            ETH_DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}
