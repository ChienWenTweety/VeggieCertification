pragma solidity ^0.4.23;

import "./VeggieCertificationStorage.sol";
import "./Ownable.sol";

contract VeggieUser is Ownable {
    
    /* Events */ 
    event UserUpdate(address indexed user, string name, string contactNo, string role, bool isActive);
    event UserRoleUpdate(address indexed user, string role); 
    
    /* Storage Variables */    
    VeggieCertificationStorage veggieCertificationStorage;
    
    constructor(address _veggieAddress) public {
        veggieCertificationStorage = VeggieCertificationStorage(_veggieAddress);
    }   
    
    
    /* Create/Update User */
    function updateUser(string _name, string _contactNo, string _role, bool _isActive) public returns(bool) {
        
        require(msg.sender != address(0));
        
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setUser(msg.sender, _name, _contactNo, _role, _isActive);
    
        /*call event*/
        emit UserUpdate(msg.sender, _name, _contactNo, _role, _isActive);
        emit UserRoleUpdate(msg.sender, _role);
        
        return status;
    }
    
    /* Create/Update User For Admin  */
    function updateUserForAdmin(address _userAddress, string _name, string _contactNo, string _role, bool _isActive) public onlyOwner returns(bool) {
        
        require(_userAddress != address(0));
        
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setUser(_userAddress, _name, _contactNo, _role, _isActive);
        
        /*call event*/
        emit UserUpdate(_userAddress, _name, _contactNo, _role, _isActive);
        emit UserRoleUpdate(_userAddress, _role);
        
        return status;
    }
    
    /* get User */
    function getUser(address _userAddress) public view returns(string name, string contactNo, string role, bool isActive, string profileHash) {
        
        require(_userAddress != address(0));
        
        /*Getting value from struct*/
       (name, contactNo, role, isActive, profileHash) = veggieCertificationStorage.getUser(_userAddress);
       
       return (name, contactNo, role, isActive, profileHash);
    }
}
