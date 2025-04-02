//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

//forge test | grep "nameOfTest" to filter out specific test

contract FundMeTest is Test {
    FundMe fundMe;

    //makeAddr creates a dummy address from a string
    address USER = makeAddr("dummy");

    //dummy amount to send
    //CONSTANT variables are not stored in storage. Instead part of the contract bytecode.
    uint256 constant testETH = 0.1 ether;

    //giving ether to dummy balance
    uint256 constant dummyBalance = 10 ether;

    //dummy gas price
    uint256 constant GAS_PRICE = 1;

    //setUp is usually the first step in testing.
    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, dummyBalance);
    }

    //the setup function runs first and then runs the next test. Upon completion, it runs the setup function again and goes to the next test function

    function testMinimumAmountTrue() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        assertEq(fundMe.getVersion(), 4);
        uint256 version = fundMe.getVersion();

        assertEq(version, 4);
    }

    function testMinimumFundAmountWorking() public {
        vm.expectRevert(); //tests a code should fail
        fundMe.fund();
    }

    function testFundUpdatesStructAfterPayment() public {
        vm.prank(USER);
        fundMe.fund{value: testETH}();

        uint256 amountDonated = fundMe.getAddressAmountFunded(USER);
        assertEq(amountDonated, testETH);
    }

    modifier fakeFunds() {
        vm.prank(USER);
        fundMe.fund{value: testETH}();
        _;
    }

    function testAddFundersToArray() public {
        vm.prank(USER);
        fundMe.fund{value: testETH}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    //vm codes dont run as transactions, they basically run in the background so they count as actual code- more like setup code

    function testOnlyOwnerCanWithdraw() public fakeFunds {
        vm.prank(USER);
        fundMe.fund{value: testETH}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithOwner() public fakeFunds {
        // Three(3) steps in testing
        // 1. Arrange/ setup the test
        // 2. type the action
        // 3. Define your assert/ what you expect

        uint256 initialOwnerBalance = fundMe.getOwner().balance;
        uint256 initialFundMeContractBalance = address(fundMe).balance;

        // anvil chains; forked or no, defaults gas price to zero. No gas
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 finalOwnerBalance = fundMe.getOwner().balance;
        uint256 finalContractBalance = address(fundMe).balance;
        assertEq(finalContractBalance, 0);
        assertEq(
            initialOwnerBalance + initialFundMeContractBalance,
            finalOwnerBalance
        );
    }

    function testFundingWithMultipleOwnersCHEAPER() public {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm.deal
            //hoax does both prank and deal
            hoax(address(i), testETH);
            fundMe.fund{value: testETH}();
        }

        uint256 initialOwnerBalance = fundMe.getOwner().balance;
        uint256 initialFundMeContractBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.gasEfficientWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            initialFundMeContractBalance + initialOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testFundingWithMultipleOwners() public {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm.deal
            //hoax does both prank and deal
            hoax(address(i), testETH);
            fundMe.fund{value: testETH}();
        }

        uint256 initialOwnerBalance = fundMe.getOwner().balance;
        uint256 initialFundMeContractBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            initialFundMeContractBalance + initialOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
