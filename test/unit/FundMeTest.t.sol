// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 constant GAS_PRICE = 1;
    FundMe fundMe;
    address USER = makeAddr("USER");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        // FundMe fundMe = new FundMe();
        // fundMe.fund();
        // fundMe.withdraw();
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        assertEq(fundMe.getAddressToAmountFunded(USER), 10e18);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function tetsOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);

        vm.expectRevert();
        // skip vm for revert

        fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

      function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.txGasPrice(GAS_PRICE);
        uint256 gasStart = gasleft();
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consummed: %d gas", gasUsed);
        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );

    }
}
