// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./PriceConverter.sol";
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MININUM_USD_VALUE = 50 * 1e18;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmount;
    address private immutable i_owner;
    AggregatorV3Interface priceFeedContract;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        priceFeedContract = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeedContract) >= MININUM_USD_VALUE,
            "Didnt sent enough ETH"
        );
        s_funders.push(msg.sender);
        s_addressToAmount[msg.sender] += msg.value;
    }

    function widthDraw() public onlyOwner {
        for (uint i = 0; i < s_funders.length; i++) {
            address funderAddress = s_funders[i];
            s_addressToAmount[funderAddress] = 0;
        }
        s_funders = new address[](0);

        // withdraw the balance to the owner
        // -----------------------------------------

        // msg.sender is the address that call the widthDraw function
        // address(this).balance is the balance(funds) of the contract
        // 3 ways can transfer native currency to a address
        // // transfer
        // payable(msg.sender.transfer(address(this).balance));
        // // send
        // bool isSuccess = payable(msg.sender.send(address(this).balance));
        // require(isSuccess, "Failed to send the funds");
        // call
        (bool isSucessCall /**return from calling func */, ) = (
            msg.sender.call{value: address(this).balance}("")
        );
        require(isSucessCall, "Failed to send the funds");
    }

    function getVersion() public returns (uint256) {
        return priceFeedContract.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "You are not the owner");

        // for more gas optimization use this
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function getAddressToAmount(
        address funderAddress
    ) external view returns (uint256) {
        return s_addressToAmount[funderAddress];
    }

    function getFunders() external view returns (address[] memory) {
        return s_funders;
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    // route to fund() function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
