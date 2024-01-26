// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../RiseInProposalContract.sol";


contract RiseInTestContractTest {

    ProposalContract proposalContract;

    function beforeAll() public {
        proposalContract = new ProposalContract();
    }

    // Test constructor
    function testConstructor() public {
        Assert.equal(proposalContract.owner(), address(this), "Owner should be the deployer");
        Assert.equal(proposalContract.votedOrNot(address(this)), true, "Deployer should be marked as voted");
    }

    // Test create()
    function testCreate() public {
        proposalContract.create("Proposal Title", "Proposal Description", 5);
        ProposalContract.Proposal memory currentProposal = proposalContract.getCurrentProposal();
        
        Assert.equal(currentProposal.title, "Proposal Title", "Title should match");
        Assert.equal(currentProposal.description, "Proposal Description", "Description should match");
        Assert.equal(currentProposal.total_vote_to_end, 5, "Total votes to end should match");
        Assert.equal(currentProposal.current_state, false, "Current state should be false");
        Assert.equal(currentProposal.is_active, true, "Proposal should be active");
    }

    // Test setNewOwner()
    function testSetNewOwner() public {
        address newOwner = address(0x1);
        proposalContract.setNewOwner(newOwner);
        Assert.equal(proposalContract.owner(), newOwner, "Owner should be updated");
    }

    // Test vote()
    function testVote() public {
        // Assuming proposal is already created in the previous test
        proposalContract.vote(1); // Approve
        ProposalContract.Proposal memory currentProposal = proposalContract.getCurrentProposal();
        
        Assert.equal(currentProposal.approve, 1, "Approve count should be 1");
        Assert.equal(currentProposal.reject, 0, "Reject count should be 0");
        Assert.equal(currentProposal.pass, 0, "Pass count should be 0");
        Assert.equal(currentProposal.current_state, false, "Current state should be false"); //current_state = true if approve>reject+(pass/2). This test FAILS.
        Assert.equal(proposalContract.votedOrNot(address(this)), true, "Deployer should be marked as voted");
    }

    // Test calculateCurrentState()
    function testCalculateCurrentState() public {
        // Assuming proposal is already created in the previous test
        proposalContract.vote(1); // Approve
        proposalContract.vote(2); // Reject
        proposalContract.vote(0); // Pass

        Assert.equal(proposalContract.calculateCurrentState(), true, "Current state should be true");
        // This fails since approve<reject+(pass/2), hence should be false
        // The voting is initialised thrice. First for approve (1 vote), Second for feject (1 vote), and third for Pass (1 VOte).
        // Hence approve < reject+(pass/2)
    }

    // Test getCurrentProposal()
    function testGetCurrentProposal() public {
        // Assuming proposal is already created in the previous test
        ProposalContract.Proposal memory currentProposal = proposalContract.getCurrentProposal();
        
        Assert.equal(currentProposal.title, "Proposal Title", "Title should match");
        Assert.equal(currentProposal.description, "Proposal Description", "Description should match");
        Assert.equal(currentProposal.total_vote_to_end, 5, "Total votes to end should match");
        Assert.equal(currentProposal.current_state, true, "Current state should be true"); // This fails as current_state by default is false. Unless using Assert.notEqual.
        Assert.equal(currentProposal.is_active, true, "Proposal should be active");
    }

    // Test getProposal(uint256 number)
    function testGetProposal() public {
        // Assuming proposal is already created in the previous test
        ProposalContract.Proposal memory specificProposal = proposalContract.getProposal(1);
        
        Assert.equal(specificProposal.title, "Proposal Title", "Title should match");
        Assert.equal(specificProposal.description, "Proposal Description", "Description should match");
        Assert.equal(specificProposal.total_vote_to_end, 5, "Total votes to end should match");
        Assert.equal(specificProposal.current_state, true, "Current state should be true"); // This fails as current_state by default is false. Unless using Assert.notEqual.
        Assert.equal(specificProposal.is_active, true, "Proposal should be active");
    }
}
