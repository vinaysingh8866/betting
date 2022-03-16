//// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

contract Betting{
    uint private totalAmount = 0;
    address[] public particepants;
    mapping(address => string) private betOfPart;
    //mapping(address => uint) private winnerVote;
    mapping(address => bool) private voted;
    mapping(address => bool) private userExists;
    mapping(address => bool) private winnerExists; 
    mapping(string => uint) private winnerCarVote;
    string[] public cars;
    uint private state = 0;
    address[] public winner;
    string private winnerCar;
    address private owner;


    constructor(string[] memory _cars, address[] memory _participants){
        particepants = _participants;
        cars = _cars;
        owner = msg.sender;
    }

    

    receive() external payable {
        totalAmount = totalAmount+msg.value;
    }

    fallback() external payable {
        totalAmount = totalAmount+msg.value;
    }

    function voteWinner(string memory _winner) public{
        uint votes = winnerCarVote[_winner];
        winnerCarVote[_winner] = votes+1;
        voted[msg.sender] = true;
    }

    function getWinner() public returns (address[] memory _winner){
        for(uint i =0; i < particepants.length; i++){
            require(voted[particepants[i]] == true, "Everyone has not voted");
        }
        uint maxVotes;
        for(uint i =0; i < cars.length; i++) {
            if(maxVotes < winnerCarVote[cars[i]]){
                maxVotes = winnerCarVote[cars[i]];
                winnerCar = cars[i];
            }
        }

        for(uint i = 0; i< particepants.length; i++){
            if(keccak256(abi.encodePacked(betOfPart[particepants[i]])) == keccak256(abi.encodePacked(winnerCar))){
                if(winnerExists[particepants[i]] == false){
                    winnerExists[particepants[i]] = true;
                    winner.push(particepants[i]);
                }
            }
        }

        return winner;
    }

    function transferAmount() public{
        require(msg.sender == owner, "Only owner can call");
        uint bal = address(this).balance;
        for(uint i = 0; i<winner.length;i++){
            (bool sent, ) = payable(winner[i]).call{value: (bal/winner.length - 10000000000000000)}("");
            require(sent, "Failed to send Ether");
        }
        selfdestruct(payable(owner));
    }

    function participate(string memory carName) public payable{
        require(userExists[msg.sender] == false," already participated");
        require(msg.value >= 100000000000000000 ,"not ok");
        userExists[msg.sender] = true;
        totalAmount = totalAmount + msg.value;
        particepants.push(msg.sender);
        betOfPart[msg.sender] = carName;
    }
}