pragma solidity ^0.4.23;

import "./VeggieSupplyChainStorage.sol";
import "./Ownable.sol";

contract VeggieSupplyChainUser is Ownable {
    
    /* Events */ 
    event UserUpdate(address indexed user, string name, string contactNo, string dept, bool isActive);
    event UserDeptUpdate(address indexed user, string dept); 
    
    /* Storage Variables */    
    VeggieSupplyChainStorage veggieSupplyChainStorage;
    
    constructor(address _address) public {
        veggieSupplyChainStorage = VeggieSupplyChainStorage(_address);
    }   
    
    /* Create/Update User */
    function updateUser(string name, string contactNo, string dept, bool isActive) public returns(bool) {
        
        require(msg.sender != address(0));
        
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setUser(msg.sender, name, contactNo, dept, isActive);
    
        /*call event*/
        emit UserUpdate(msg.sender, name, contactNo, dept, isActive);
        emit UserDeptUpdate(msg.sender, dept);
        
        return status;
    }
    
    /* Create/Update User For Admin */
    function updateUserForAdmin(address userAddress, string name, string contactNo, string dept, bool isActive) public onlyOwner returns(bool) {
        
        require(userAddress != address(0));
        
        /* Call Storage Contract */
        bool status = veggieSupplyChainStorage.setUser(userAddress, name, contactNo, dept, isActive);
        
        /*call event*/
        emit UserUpdate(userAddress, name, contactNo, dept, isActive);
        emit UserDeptUpdate(userAddress, dept);
        
        return status;
    }
    
    /* get User */
    function getUser(address userAddress) public view returns(string name, string contactNo, string role, bool isActive) {
        
        require(userAddress != address(0));
        
        /*Getting value from struct*/
        (name, contactNo, role, isActive) = veggieSupplyChainStorage.getUser(userAddress);
       
        return (name, contactNo, role, isActive);
    }
}
