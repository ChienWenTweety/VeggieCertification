pragma solidity ^0.4.23;

import "./VeggieCertificationStorage.sol";
import "./Ownable.sol";

contract VeggieCertification is Ownable 
{
    
    event DoneImport(address indexed user, address indexed batchNo);
    event DoneInspection(address indexed user, address indexed batchNo);
    event DoneEnterWarehouse(address indexed user, address indexed batchNo);


  /*Modifier*/
    modifier isValidPerformer(address batchNo, string role) {
        
    
        require(keccak256('RECEIVER') == keccak256(role),veggieCertificationStorage.getUserRole(msg.sender));
        require(keccak256(veggieCertificationStorage.getNextAction(batchNo)) == keccak256(role),"qqq");
        _;
    }


    VeggieCertificationStorage veggieCertificationStorage;

     constructor()  public payable{
        veggieCertificationStorage = new VeggieCertificationStorage();
    }   
    
    /* Get Next Action  */    

    function getNextAction(address _batchNo) public view returns(string action)
    {
       (action) = veggieCertificationStorage.getNextAction(_batchNo);
       return (action);
    }
    

    

     /* get Basic Details */
    
    function getBasicDetails(address _batchNo) public view returns (string registrationNo,
                                                                     string companyName,
                                                                     string companyAddress) {
        /* Call Storage Contract */
        (registrationNo, companyName, companyAddress) = veggieCertificationStorage.getBasicDetails(_batchNo);  
        return (registrationNo, companyName, companyAddress);
    }

    /*  */
    
    function addBasicDetails(string _registrationNo,
                             string _companyName,
                             string _companyAddress) public onlyOwner returns(address) {
    
        address batchNo = veggieCertificationStorage.setBasicDetails(_registrationNo,
                                                            _companyName,
                                                            _companyAddress);
        
        emit DoneImport(msg.sender, batchNo); 
        
        return (batchNo);
    }

/* shipName: Name of Logistics company     shipNo:Car license Number */
 function getReceiverData(address _batchNo) public view returns (string transportInfo,
                                                                    uint256 quantity,
                                                                    string shipName,
                                                                    string shipNo,
                                                                    uint256 arrivalDateTime,
                                                                    string farmerName,
                                                                    string farmAddress) {
                                                                    
        /* Call Storage Contract */
        (transportInfo,
         quantity,
         shipName,
         shipNo,
         arrivalDateTime,
         farmerName,
         farmAddress) =  veggieCertificationStorage.getReceiverData(_batchNo);  
         
         return (transportInfo,
                 quantity,
                 shipName,
                 shipNo,
                 arrivalDateTime,
                 farmerName,
                 farmAddress);
        
    }
    
    /* perform Receiver */
    
    function updateReceiverData(address _batchNo,
                                string _transportInfo,
                                uint256 _quantity, 
                                string _shipName,
                                string _shipNo,
                                string _farmerName,
                                string _farmAddress)
                                public isValidPerformer(_batchNo,'RECEIVER') returns(bool) {
                                    
        /* Call Storage Contract */
        
        bool status = veggieCertificationStorage.setReceiverData( _batchNo,_transportInfo, _quantity, _shipName, _shipNo, _farmerName, _farmAddress);
        require (status == true, "aaa");
        emit DoneImport(msg.sender, _batchNo);
        return (status);
    }

    function getInspectorData(address _batchNo) public view returns (uint256 arrivalDateTime) {
        /* Call Storage Contract */
        (arrivalDateTime) = veggieCertificationStorage.getInspectorData(_batchNo);  
        return (arrivalDateTime);
    }
    
    /* perform Farm Inspection */
    
    function updateInspectorData(address _batchNo,
                                   string _transportInfo,
                                    uint256 _quantity) 
                                public isValidPerformer(_batchNo,'PROCESSOR') returns(bool) {
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setInspectorData( _batchNo,  _transportInfo, _quantity);  
        
        emit DoneInspection(msg.sender, _batchNo);
        return (status);
    }
    
    
    /* get Processor */
    
    function getwarehouseManagerData(address _batchNo) public view returns (uint256 stockNumber) {
        /* Call Storage Contract */
        (stockNumber) =  veggieCertificationStorage.getwarehouseManagerData(_batchNo);  
         
         return (stockNumber);
 
    }
    
    /* perform Processing */
    
    function updatewarehouseManagerData(address _batchNo,
                              uint256 _stockNumber) public isValidPerformer(_batchNo,'WAREHOUSE') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setwarehouseManagerData(_batchNo, _stockNumber);  
        
        emit DoneEnterWarehouse(msg.sender, _batchNo);
        return (status);
    }
}
