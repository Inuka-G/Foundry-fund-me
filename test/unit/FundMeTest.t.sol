// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

// when using fork url for testing local chain fork live test net for testing
contract FundMeTest is Test {
    address USER = makeAddr("inukaG"); //return a fake address for a name
    FundMe fundMe;
    uint256 constant FUNDING_AMOUNT = 10e18;
    uint256 constant STARTING_USER_BALANCE = 1000 ether;

    function setUp() external {
        vm.deal(USER, STARTING_USER_BALANCE); // give USER some ether
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumUsdValue() public {
        assertEq(fundMe.MININUM_USD_VALUE(), 5e19);
    }

    function testOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionOfPriceFeed() public {
        // fundMe.getVersion();
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundWithNotEnoughEth() public {
        vm.expectRevert(); //next lines should revert
        fundMe.fund();
    }

    function testFundUpdateDataStructures() public {
        vm.prank(USER); //vm.prank set msg.sender to a specific addresss for next call
        fundMe.fund{value: FUNDING_AMOUNT}();
        uint256 amountFunded = fundMe.getAddressToAmount(USER);
        assertEq(amountFunded, FUNDING_AMOUNT);
    }

    function testFundUpdateFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: FUNDING_AMOUNT}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.expectRevert(); //next lines should revert
        fundMe.widthDraw();
    }
}
