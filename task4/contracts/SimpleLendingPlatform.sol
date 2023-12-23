// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleLendingPlatform {
    struct User {
        uint depositedTokens;
        uint collateraledTokens;
        uint borrowedExchangedTokens;
        uint lastUpdate;
    }

    uint totalTokens;

    address owner;

    ERC20 token;
    uint public supplyRateToken = 5;
    uint public borrowRateExchangedToken = 10;

    ERC20 exhcangedToken;

    uint decimals;

    mapping(address => User) users;

    uint collateralFactor = 75;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    constructor(address _tokenFirst, address _tokenSecond) {
        owner = msg.sender;
        token = ERC20(_tokenFirst);
        exhcangedToken = ERC20(_tokenSecond);
        decimals = token.decimals();
    }

    function supplyRate() public view returns (uint) {
        return supplyRateToken;
    }

    function borrowRate() public view returns (uint) {
        return borrowRateExchangedToken;
    }

    uint constant kCoef = 10 ** 2;

    function _update() internal {
        // if (getDeposit() == 0) {
        //     return;
        // }
        if (users[msg.sender].lastUpdate > 0) {
            uint deltaYears = (block.timestamp - users[msg.sender].lastUpdate) /
                (360 * 24 * 60 * 60);
            if (deltaYears > 0) {
                users[msg.sender].depositedTokens = ((getDeposit() *
                    (kCoef * 1 + ((kCoef * supplyRate()) / 100) / 360) **
                        deltaYears) / (kCoef ** deltaYears));
            }
        }
        users[msg.sender].lastUpdate = block.timestamp;
    }

    function deposit(uint amount) external payable {
        _update();
        // require(token.approve(address(this), amount), "approve failed");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "deposit failed"
        );
        users[msg.sender].depositedTokens += amount;
        totalTokens += amount;
    }

    function getDeposit() public view returns (uint) {
        return users[msg.sender].depositedTokens;
    }

    function borrowedTokens() public view returns (uint) {
        return users[msg.sender].borrowedExchangedTokens;
    }

    function amountCanBorrow() public view returns (uint) {
        return ((users[msg.sender].collateraledTokens * collateralFactor) /
            100 -
            borrowedTokens());
    }

    function getColloteral() public view returns (uint) {
        return users[msg.sender].collateraledTokens;
    }

    function addColloteral(uint amount) public {
        // _update();
        require(
            users[msg.sender].depositedTokens >= amount,
            "not enough deposit"
        );
        users[msg.sender].depositedTokens -= amount;
        users[msg.sender].collateraledTokens += amount;
    }

    function takeColloteral(uint amount) public {
        // _update();
        require(
            users[msg.sender].collateraledTokens >= amount,
            "not enough collateral"
        );
        users[msg.sender].collateraledTokens -= amount;
        users[msg.sender].depositedTokens += amount;
    }

    function setColloteral(uint amount) external {
        // _update();

        if (amount >= getColloteral()) {
            addColloteral(amount - getColloteral());
        } else {
            require(
                borrowedTokens() <=
                    ((getColloteral() - amount) * collateralFactor) / 100
            );
            takeColloteral(getColloteral() - amount);
        }
    }

    // function withdrawDeposit(uint amount) external {
    //     _update();
    //     require(users[msg.sender].depositedTokens > amount);

    //     require(
    //         token.transferFrom(address(this), msg.sender, amount),
    //         "withdraw deposit failed"
    //     );
    // }

    function withdrawAllDdeposit() external {
        _update();
        require(users[msg.sender].depositedTokens > 0);

        require(
            token.approve(address(this), users[msg.sender].depositedTokens),
            "approve failed"
        );

        require(
            token.transferFrom(
                address(this),
                msg.sender,
                users[msg.sender].depositedTokens
            ),
            "withdraw All deposit failed"
        );
    }

    function borrowExchangedTokens(uint amount) external {
        // _update();
        require(amountCanBorrow() >= amount, "you can not borrow this amount");
        users[msg.sender].borrowedExchangedTokens += amount;
        require(
            exhcangedToken.approve(address(this), amount),
            "approve failed"
        );
        require(
            exhcangedToken.transferFrom(address(this), msg.sender, amount),
            "borrowExchangedTokens failed"
        );
    }

    function getAmountToRepay() public view returns (uint) {
        uint deltaYears = (block.timestamp - users[msg.sender].lastUpdate) /
            (360 * 24 * 60 * 60);
        return
            (borrowedTokens() *
                ((kCoef * 1 + (kCoef * borrowRate()) / 100)) ** deltaYears) /
            kCoef ** deltaYears;
    }

    function repayDebt(uint amount) external {
        // _update();
        require(amount > 0, "you can not repay 0 tokens");
        require(
            amount <= getAmountToRepay(),
            "your debt is less than you want to sent"
        );
        uint deltaYears = (block.timestamp - users[msg.sender].lastUpdate) /
            (360 * 24 * 60 * 60);
        users[msg.sender].borrowedExchangedTokens -= ((amount *
            (kCoef ** deltaYears)) /
            (1 * kCoef + (kCoef * borrowRate()) / 100) ** deltaYears);
    }
}
