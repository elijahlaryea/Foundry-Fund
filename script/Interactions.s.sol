//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

//to interact with our contracts
//1. fund script and 2.withdraw script

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

//contract to fund the fundMe contract

contract FundFundMe is Script {
    uint256 constant test_Amount = 0.01 ether;

    function fundFundMe(address recentlyDeployed) public {
        FundMe(payable(recentlyDeployed)).fund{value: test_Amount}();

        console.log("You funded the FundMe contract");
    }

    function run() external {
        address recentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(recentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address recentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(recentlyDeployed)).withdraw();
        vm.stopBroadcast();

        console.log("You funded the FundMe contract");
    }

    function run() external {
        address recentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(recentlyDeployed);
        vm.stopBroadcast();
    }
}
