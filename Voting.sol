// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

contract Ballot {
   
    struct Voter {
        uint weight; 
        bool voted; 
        uint vote;
    }

    struct Candidate {
        string name;  
        uint voteCount; 
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    Candidate[] public candidates;
    
    enum State { Created, Voting, Ended } 
    
    State public state;

    constructor(string[] memory candidateNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        state = State.Created;
        
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }
    
   
    modifier onlySmartContractOwner() {
        require(
            msg.sender == chairperson,
            "Only chairperson can start and end the voting"
        );
        _;
    }
    
    modifier CreatedState() {
        require(state == State.Created, "it must be in Started");
        _;
    }
    
    modifier VotingState() {
        require(state == State.Voting, "it must be in Voting Period");
        _;
    }
    
    modifier EndedState() {
        require(state == State.Ended, "it must be in Ended Period");
        _;
    }
    
    function addCandidates(string[] memory candidateNames) 
        public 
        EndedState
    {
        state = State.Created;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }
    
    
    function startVote() 
        public
        onlySmartContractOwner
        CreatedState
    {
        state = State.Voting;
    }
    
    
    function endVote() 
        public 
        onlySmartContractOwner
        VotingState
    {
        state = State.Ended;
    }
    
    
    
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    
    function vote(uint candidate) 
        public
        VotingState
    {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = candidate;

        
        candidates[candidate].voteCount += sender.weight;
    }

    function winningCandidate() 
        public
        EndedState
        view
        returns (string memory winnerName_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < candidates.length; p++) {
            if (candidates[p].voteCount > winningVoteCount) {
                winningVoteCount = candidates[p].voteCount;
                winnerName_ = candidates[p].name;
            }
        }
    }
}
