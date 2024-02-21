// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/*
* @author Kz
*/
contract CrowdFundingBase {

    event ContributionReceived(address participant, uint256 amount, uint256 projectID);
    event ProjectCreated(uint256 projectID, string title);
    event Sent(address withdrawer, uint amount);

    struct Project {
        uint256 projectID;
        string projectTitle;
        string projectDescription;
        address projectOwner;
        uint256 projectParticipationAmount;
        uint256 projectTotalFundingAmount;           
    }
    
    mapping(uint256 => Project) projects; //projectID => Project
    uint256[] public projectIDs; // Keep track of all project IDs
    mapping(uint256 => address[]) projectParticipants; // Keep track of all participants of a particular project     
    mapping(uint256 => mapping(address => uint256)) contributions; // To keep track of individual contributions        
    uint256 projectCounter;   

    /*
     *
     */
    function createProject(string memory _title, string memory _description) public {

        require(bytes(_title).length > 0 && bytes(_description).length > 0 , "Project title & description must be set");
       
        projects[projectCounter] = Project({
            projectID: projectCounter,
            projectTitle: _title,
            projectDescription: _description,
            projectOwner: msg.sender,
            projectParticipationAmount: 0,
            projectTotalFundingAmount: 0
        });
       
        projectIDs.push(projectCounter);
        projectCounter++;        

        emit ProjectCreated(projectCounter, _title);
    }

    /*
     * Partipant must call this function to participate(participant = msg.sender)
     * 1. Update/add new contribution by the participant
     * 2. Update partipant count
     * 3. Update total funding
     */
    function participateToProject(uint256 _projectID) public payable {

        require(msg.value > 0, "Contribution needs to be >0 in order to paricipate");

        //Check if the project exists --- expensive
        bool found = false;
        for(uint256 i = 0; i < projectIDs.length; i++){
            if(projectIDs[i] == _projectID){
                found = true;
                break;
            }
        }
        require(found, "Project doesn't exist");

        Project storage p = projects[_projectID];

        //Add previous contributions of this participant for the project
        uint256 previousContribution = contributions[_projectID][msg.sender];
        contributions[_projectID][msg.sender] += msg.value;

        //Update participants only if new user
        if(previousContribution == 0){
            p.projectParticipationAmount++;
            projectParticipants[_projectID].push(msg.sender);
        }

        //Update total funding for the project
        p.projectTotalFundingAmount += msg.value;

        emit ContributionReceived(msg.sender, msg.value, _projectID);
    }


    /*
     * @return title, description, owner, number of partipants, total funding
     */
    function searchForProject(uint256 _projectID) public view returns (string memory, string memory, address, uint256, uint256){

        Project storage p = projects[_projectID];
        return (
            p.projectTitle,
            p.projectDescription,
            p.projectOwner,
            p.projectParticipationAmount,
            p.projectTotalFundingAmount
        );
    }

    /*
    * @return array of participants/contributers for a given project
    */
    function getContributers(uint256 _projectID) public view returns(address[] memory) {
        return projectParticipants[_projectID];
    }

    /*
     * @param participant address, projectID
     * @return contributed amount of a particular participant for a particular project
     */
    function retrieveContributions(address _addr, uint256 _projectID) public view returns (uint256) {
        return contributions[_projectID][_addr];
    }

    /*
     * Only the owner of a project can withdraw funds and total funds 
     * contributed to a given project will be sent to the msg.sender
     */
    function withdrawFunds(uint256 _projectID) public {

        Project storage prj = projects[_projectID];
        require(msg.sender == prj.projectOwner, "Must be project owner");

        // Total balance of the contract must always be greater than or equal to the available funding for a particular project
        require(address(this).balance >= prj.projectTotalFundingAmount, "CODE RED: missing funds."); 
       
        (bool success,) = msg.sender.call{value: prj.projectTotalFundingAmount}("");        
        if(!success){
            revert("Withdrawal unsuccessfull");
        }else{            
            emit Sent(msg.sender, prj.projectTotalFundingAmount); 
            prj.projectTotalFundingAmount = 0;           
        }
    }}