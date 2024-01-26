// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    uint256 private counter; // To keep track of proposal IDs, the uint256, in proposal_history.
    address public owner;  // Made public so to allow access in test.
    address[]  private voted_addresses; // Keep track of voted addresses.
    

    struct Proposal {
        string title; // Task 1
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass;                                                                                     // WHY USE?
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal based on the number of votes (and ends the proposal when the vote limit is reached.)  // LOGIC?
        bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) public proposal_history; // History of previous proposals
    mapping(address => bool) public isVoted;

   modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isActive() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted[_address], "Address has already voted");
        _;
    }

    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender); //Prevents owner from voting in their proposals.
    }

    // Task 2: Add title as function parameter.
    function create(string memory _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1; // No proposal will be found at proposal_history[0]. Unless hardcoded in constructor and counter logic moved 2lines down.
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
    }

    function setNewOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function vote(uint8 choice) external isActive newVoter(msg.sender){
        // Function logic
        // First part
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        /*
        Second part
        Approve -> will be represented by 1.
        Reject -> will be represented by 2.
        Pass -> will be represented by 0.
        */

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        // Third part
        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {  // WHY THIS (proposal.total_vote_to_end - total_vote == 1)?
            proposal.is_active = false;
            voted_addresses = [owner];  // WHY =[owner]?
        }
    }

    function calculateCurrentState() public view returns(bool) { // Initially private. Set to public to allow test file access.
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        /*
        For a proposal to succeed, the number of approve votes should be > sum of reject and half the pass votes
        (you can think like pass vote has the half the impact).
        So, our formula is: approve = reject + (pass / 2)
        You may have odd number of pass votes which cannot be divided by two.
        In these cases, you add 1 to the number of pass votes and then divide.
        */
            
        if (proposal.pass %2 == 1) {
            pass += 1;
        }

        pass = pass / 2;

        if (approve > reject + pass) {
            return true;
        } else {
            return false;
        }
    }

    function teminateProposal() external onlyOwner isActive {
        proposal_history[counter].is_active = false;
    }

    // Will retrieve whether a given address has voted or not.
    function votedOrNot (address _address) public view returns (bool) {
        // OR USE THIS EASY ITERABLE LOGIC
        // return isVoted[_address];
        for (uint i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;

        
        
    }

    // Basic getter function to retrieve the current proposal
    function getCurrentProposal() external view returns(Proposal memory) {
        return proposal_history[counter];
    }

    // Gets a specific proposal
    function getProposal(uint256 number) external view returns(Proposal memory) {
        return proposal_history[number];
    }
    
}