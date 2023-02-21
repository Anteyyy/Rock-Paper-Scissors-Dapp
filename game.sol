// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    //modifier onlyOwner
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //Owner's address
    address owner;

    //event to track result of game
    event GamePlayed(address player, uint256 amount, uint8 option, uint8 randomOption, uint256 payout);

    //payable = user может заплатить в BNB (главная монета в блокчейне)
    //in Constructor we assign owner's address;
    constructor() payable {
        owner = msg.sender;
    }

    //function that asks for 0, 1 or 2 and returns if you win or lose
    function play(uint8 _option) public payable returns (uint256) { //view, pure = gassless 
        require(_option < 3, "Please select rock, paper or scissors");
        require(msg.value > 0, "Please add your bet"); //WEI smallest unit ETH 
        require(msg.value * 3 <= address(this).balance, "Contract balance is insufficient");

        //PseudoRandom
        uint8 randomOption = uint8(block.timestamp * block.gaslimit % 3);

        //If user and random option are the same, payout is equal to bet
        if (_option == randomOption) {
            payable(msg.sender).transfer(msg.value);
            emit GamePlayed(msg.sender, msg.value, _option, randomOption, msg.value);
            return msg.value;
        }

        //Calculate the winner and the payout
        uint256 payout;
        if ((_option == 0 && randomOption == 2) || (_option == 1 && randomOption == 0) || (_option == 2 && randomOption == 1)) {
            payout = msg.value * 3;
        } else {
            payout = 0;
        }

        //Emiting event of game play
        emit GamePlayed(msg.sender, msg.value, _option, randomOption, payout);

        //If user wins, transfer the payout to them
        if (payout > 0) {
            payable(msg.sender).transfer(payout);
        }

        return payout;
    }

    //Owner can withdraw BNB amount
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    fallback() external payable {

    }

    receive() external payable {
        
    }
}
