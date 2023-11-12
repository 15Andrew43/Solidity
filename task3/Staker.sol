pragma solidity ^0.8.20;

import "./nft.sol";

contract Staker {
    address owner;
    address payable externalContract;

    uint immutable deadline;
    uint immutable ethereumTreshold;

    mapping (address => uint) balances;
    mapping (address => bool) hasNFT;
    uint ethereumTotal = 0;

    uint constant bronzeLevel = 1 ether;
    uint constant silverLevel = 2 ether;
    uint constant goldLevel = 5 ether;

    bool isCompleted = false;
    bool canWithDraw = false;

    MyNFT bronzeNFT;
    MyNFT silverNFT;
    MyNFT goldNFT;


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "deadline has not happened");
        _;
    }

    constructor(uint _delay, uint _ethereumTreshold, address _externalContract) {
        owner = msg.sender;
        deadline = block.timestamp + _delay;
        ethereumTreshold = _ethereumTreshold;
        externalContract = payable(_externalContract);

        bronzeNFT = new MyNFT("bronze", "BRZ");
        silverNFT = new MyNFT("silver", "SLR");
        goldNFT = new MyNFT("gold", "GLD");
    }

    function complete() private {
        isCompleted = true;
    }

    function endStaking() external onlyOwner afterDeadline {
        require(!isCompleted, "Staking is alreadi completed");
        if (!canWithDraw && ethereumTotal < ethereumTreshold) {
            canWithDraw = true;
        } else {
            externalContract.transfer(address(this).balance);
        }
        complete();
    }

    function withDraw() external payable afterDeadline {
        if (!canWithDraw && ethereumTotal < ethereumTreshold) {
            canWithDraw = true;
        }
        require(canWithDraw, "you can not withdraw");

        payable(msg.sender).transfer(balances[msg.sender]);
        delete balances[msg.sender];
    }

    function getNFT() external {
        require(isCompleted, "Staking has not finished");
        require(balances[msg.sender] >= bronzeLevel, "you sent not enouth ether");

        if (balances[msg.sender] >= goldLevel) {
            goldNFT.mint(msg.sender);
        } else if (balances[msg.sender] >= silverLevel) {
            silverNFT.mint(msg.sender);
        } else if (balances[msg.sender] >= bronzeLevel) {
            bronzeNFT.mint(msg.sender);
        }

        hasNFT[msg.sender] = true;
    }

    receive() external payable {
        require(!isCompleted, "Staking is completed");

        balances[msg.sender] += msg.value;
        ethereumTotal += msg.value;
    }
}
