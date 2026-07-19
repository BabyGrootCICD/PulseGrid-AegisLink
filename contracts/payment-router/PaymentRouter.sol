// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PaymentRouter {
    address public owner;
    mapping(address => bool) public approvedRouters;
    
    event PaymentRouted(address indexed from, address indexed to, uint256 amount, string currency);
    event RouterApproved(address indexed router, bool approved);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    modifier onlyApprovedRouter() {
        require(approvedRouters[msg.sender], "Not an approved router");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function approveRouter(address _router, bool _approved) external onlyOwner {
        approvedRouters[_router] = _approved;
        emit RouterApproved(_router, _approved);
    }

    function routePayment(
        address _to,
        string memory _currency
    ) external onlyApprovedRouter payable {
        require(msg.value > 0, "Amount must be greater than 0");

        (bool success, ) = _to.call{value: msg.value}("");
        require(success, "Payment transfer failed");

        emit PaymentRouted(msg.sender, _to, msg.value, _currency);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    receive() external payable {}
}
