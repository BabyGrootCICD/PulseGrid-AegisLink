// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TipEscrow {
    struct Tip {
        address sender;
        address recipient;
        uint256 amount;
        uint256 timestamp;
        bool released;
        bool refunded;
    }

    mapping(uint256 => Tip) public tips;
    uint256 public tipCount;
    address public platformWallet;
    uint256 public platformFeePercent;

    event TipCreated(uint256 indexed tipId, address indexed sender, address indexed recipient, uint256 amount);
    event TipReleased(uint256 indexed tipId, uint256 amount);
    event TipRefunded(uint256 indexed tipId, uint256 amount);

    modifier onlyPlatform() {
        require(msg.sender == platformWallet, "Only platform can call");
        _;
    }

    constructor(address _platformWallet, uint256 _platformFeePercent) {
        platformWallet = _platformWallet;
        platformFeePercent = _platformFeePercent;
    }

    function createTip(address _recipient) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        
        tipCount++;
        tips[tipCount] = Tip({
            sender: msg.sender,
            recipient: _recipient,
            amount: msg.value,
            timestamp: block.timestamp,
            released: false,
            refunded: false
        });

        emit TipCreated(tipCount, msg.sender, _recipient, msg.value);
    }

    function releaseTip(uint256 _tipId) external {
        Tip storage tip = tips[_tipId];
        require(tip.sender == msg.sender || tip.recipient == msg.sender, "Not authorized");
        require(!tip.released && !tip.refunded, "Tip already processed");

        tip.released = true;
        uint256 fee = (tip.amount * platformFeePercent) / 100;
        uint256 recipientAmount = tip.amount - fee;

        (bool success, ) = tip.recipient.call{value: recipientAmount}("");
        require(success, "Transfer failed");

        if (fee > 0) {
            (bool feeSuccess, ) = platformWallet.call{value: fee}("");
            require(feeSuccess, "Fee transfer failed");
        }

        emit TipReleased(_tipId, tip.amount);
    }

    function refundTip(uint256 _tipId) external {
        Tip storage tip = tips[_tipId];
        require(tip.sender == msg.sender, "Only sender can refund");
        require(!tip.released && !tip.refunded, "Tip already processed");
        require(block.timestamp - tip.timestamp < 24 hours, "Refund window expired");

        tip.refunded = true;

        (bool success, ) = tip.sender.call{value: tip.amount}("");
        require(success, "Refund failed");

        emit TipRefunded(_tipId, tip.amount);
    }

    function getTip(uint256 _tipId) external view returns (Tip memory) {
        return tips[_tipId];
    }
}
