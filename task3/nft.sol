pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";


interface ItokenNFT {
    function mint(address _to) external;
    function burn(address _from, uint _tokenId) external returns (bool);
    function transferFrom(address _from, address _to, uint _tokenId) external returns (bool);

    event Transfer(address _from, address _to, uint tokenId);
}

contract MyNFT is ItokenNFT, Ownable {
    string name;
    string symbol;
    mapping (address => uint[]) public tokens;
    uint tokenId = 1;

    constructor(string memory _name, string memory _symbol) Ownable(msg.sender) {
        name = _name;
        symbol = _symbol;
    }

    function getNextTokenId() private returns (uint) {
        tokenId++;
        return tokenId;
    }

    function mint(address _to) external onlyOwner {
        uint _tokenId = getNextTokenId();
        tokens[_to].push(_tokenId);

        emit Transfer(address(0), _to, _tokenId);
    }

    function burn(address _from, uint _tokenId) external onlyOwner returns (bool) {
        for (uint i = 0; i < tokens[_from].length; i++) {
            if (tokens[_from][i] == _tokenId) {
                tokens[_from][i] = tokens[_from][tokens[_from].length - 1];
                tokens[_from].pop();

                emit Transfer(_from, address(0), _tokenId);
                return true;
            }
        }
        return false;
    }
    function transferFrom(address _from, address _to, uint _tokenId) external returns (bool) {
        for (uint i = 0; i < tokens[_from].length; i++) {
            if (tokens[_from][i] == _tokenId) {
                tokens[_from][i] = tokens[_from][tokens[_from].length - 1];
                tokens[_from].pop();

                tokens[_to].push(_tokenId);

                emit Transfer(_from, _to, _tokenId);
                return true;
            }
        }
        return false;
    }
}