//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 1 ether;
    uint256 GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testUserCanFundInteractions() public {
        vm.startPrank(USER);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe{value: 1 ether}(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder, address(fundFundMe));
        vm.stopPrank();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}
