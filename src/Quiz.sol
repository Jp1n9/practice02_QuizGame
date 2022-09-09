// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(uint => mapping(address => uint256)) public bets;
    // mapping(address => uint256)[] public bets;
    address owner;
    uint public vault_balance;
    Quiz_item[] quizs;
    mapping(address => uint256) bal;

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        Quiz_item memory dum;
        addQuiz(q);    
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        
        require(owner == msg.sender);
        quizs.push(q);
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return quizs[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q=quizs[quizId];
        q.answer = "";
        return q;
    }

    function getQuizNum() public view returns (uint){
        return quizs.length-1;
    }
    
    function betToPlay(uint quizId) public payable {
        uint256 ethValue = msg.value;
        Quiz_item memory q = quizs[quizId];
        uint idx = quizId-1;
        require(q.max_bet >= ethValue);
        require(q.min_bet <= ethValue);


        bets[idx][msg.sender]+=msg.value;

    }

  


    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q = quizs[quizId];
        uint256 idx = quizId-1;
        if(keccak256(abi.encodePacked(q.answer)) != keccak256(abi.encodePacked(ans))){
            vault_balance+=bets[idx][msg.sender];
            bets[idx][msg.sender] = 0;
            return false;
        }
        bal[msg.sender] = q.min_bet*2;

        return true;
    }

    function claim() public {
        uint256 balance = bal[msg.sender];
        bal[msg.sender]=0;
        (bool isSuccess,)=msg.sender.call{value:balance}("");
        assert(isSuccess);
    }

    receive() external payable {
        vault_balance+=msg.value;
    }
}
