// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./ownable.sol";
import "./MyToken.sol";

import "./MathLib.sol";

contract AndreyToken is MyToken {
    constructor() MyToken("AndreyToken", "ABT") {}
}

contract Crowdsale is Ownable {
    using Math for uint;

    address payable owner_;
    uint exchangeRate_ = 1000 wei; // 1000 wei = 1 token
    AndreyToken token_;
    uint timeStart_;
    uint duration_ = 5 seconds;
    bool isFinished_ = false;
    uint percent2Developers = 10;
    address[] public developersAddresses;
    uint limitSpends = 100_000 wei;
    mapping(address => uint) public ethsSpent;

    constructor() Ownable() {
        timeStart_ = block.timestamp;
        token_ = new AndreyToken();
        // owner_ = payable(msg.sender);
    }

    function setDevelopersAddresses(
        address[] memory addresses
    ) public onlyOwner {
        developersAddresses = addresses;
    }

    function checkIsFinished() internal {
        // это нерпавильно, так как по истечению crowdsale смогут
        // выполняться только view функии,
        // а они не создают транзщакции, поэтому не очень ясно
        // как по истечению этого времени выпустить 10 поцентов команде
        if (!isFinished_ && block.timestamp >= timeStart_ + duration_) {
            isFinished_ = true;
            transfer2Developers();
        }
    }

    function transfer2Developers() private {
        uint extraTokens = (token_.totalNumber() * percent2Developers) / 100;
        for (uint i = 0; i < developersAddresses.length; i++) {
            token_.addTokens(
                developersAddresses[i],
                extraTokens / developersAddresses.length
            );
        }
    }

    receive() external payable {
        checkIsFinished();

        require(!isFinished_, "Crowdsale is finished");
        require(msg.value >= exchangeRate_, "not enought ethereum");
        require(
            ethsSpent[msg.sender] + exchangeRate_ <= limitSpends,
            "you bought too much tokens"
        );

        uint nTokens = Math.min(
            msg.value,
            (limitSpends - ethsSpent[msg.sender])
        ) / exchangeRate_;

        token_.addTokens(msg.sender, nTokens);
        ethsSpent[msg.sender] += nTokens * exchangeRate_;

        payable(msg.sender).transfer(msg.value % exchangeRate_);

        sendFunds2Owner();
    }

    function buyTokens(uint nTokens) external payable {
        checkIsFinished();

        require(!isFinished_, "Crowdsale is finished");
        require(msg.value >= exchangeRate_ * nTokens, "not enought ethereum");
        require(
            ethsSpent[msg.sender] + exchangeRate_ * nTokens <= limitSpends,
            "you bought too much tokens"
        );

        token_.addTokens(msg.sender, nTokens);
        ethsSpent[msg.sender] += exchangeRate_ * nTokens;

        payable(msg.sender).transfer(msg.value - exchangeRate_ * nTokens);

        sendFunds2Owner();
    }

    function sendFunds2Owner() private {
        owner_.transfer(address(this).balance);
    }

    function balanceOf(address _address) external view returns (uint) {
        return token_.balanceOf(_address);
    }
}
