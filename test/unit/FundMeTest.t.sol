// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

// when using fork url for testing local chain fork live test net for testing
contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUsdValue() public {
        assertEq(fundMe.MININUM_USD_VALUE(), 5e19);
    }

    function testOwner() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testVersionOfPriceFeed() public {
        // fundMe.getVersion();
        assertEq(fundMe.getVersion(), 4);
    }
}
