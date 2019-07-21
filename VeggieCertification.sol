pragma solidity ^0.4.23;

import "./VeggieCertificationStorage.sol";
import "./Ownable.sol";

contract VeggieCertification is Ownable {
    
    event DonePurchase(address indexed user, address indexed batchNo);
    event DoneInspection(address indexed user, address indexed batchNo);
    event DoneEnterWarehouse(address indexed user, address indexed batchNo);
    event DoneNewBatch(address indexed user, address indexed newBatchNo); 
    event DoneShipping(address indexed user, address indexed newbatchNo);
    event DoneSales(address indexed user, address indexed newbatchNo);

    /* Modifier */
    modifier isValidPerformer(address batchNo, string role) {
        
        require(keccak256(veggieCertificationStorage.getUserRole(msg.sender)) == keccak256(role));
        require(keccak256(veggieCertificationStorage.getNextAction(batchNo)) == keccak256(role));
        _;
    }

    VeggieCertificationStorage veggieCertificationStorage;

    constructor(address _veggieAddress) public {
        veggieCertificationStorage = VeggieCertificationStorage(_veggieAddress);
    }   
    
    /* Add New User */
    /*function addUser(address _userAddress,
                     string _name, 
                     string _contactNo, 
                     string _role, 
                     bool _isActive) public onlyOwner returns(bool) {
    
        bool status = veggieCertificationStorage.setUser(_userAddress,
                                                         _name, 
                                                         _contactNo, 
                                                         _role, 
                                                         _isActive);
        
        //emit DONEAddUser(msg.sender, );//
        
        return (status);
    }
    */   
    
    /* Get Next Action */    

    function getNextAction(address _batchNo) public view returns(string action) {
        (action) = veggieCertificationStorage.getNextAction(_batchNo);
        return (action);
    }
    
    /* Get Basic Details */
    
    function getBasicDetails(address _batchNo) public view returns(string registrationNo,
                                                                   string companyName,
                                                                   string companyAddress) {
        /* Call Storage Contract */
        (registrationNo, companyName, companyAddress) = veggieCertificationStorage.getBasicDetails(_batchNo);  
        return (registrationNo, companyName, companyAddress);
    }

    /* Generate Batch Number */
    
    function addBasicDetails(string _registrationNo,
                             string _companyName,
                             string _companyAddress) public onlyOwner returns(address) {
    
        address batchNo = veggieCertificationStorage.setBasicDetails(_registrationNo,
                                                                     _companyName,
                                                                     _companyAddress);
        
        emit DonePurchase(msg.sender, batchNo); 
        return (batchNo);
    }

    /* shipName: Name of Logistics company, shipNo:Car license Number */
    
    function getReceiverData(address _batchNo) public view returns(string transportInfo,
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
    
    /* Perform Receiving */
    
    function updateReceiverData(address _batchNo,
                                string _transportInfo,
                                uint256 _quantity, 
                                string _shipName,
                                string _shipNo,
                                string _farmerName,
                                string _farmAddress)
                                public isValidPerformer(_batchNo, 'RECEIVER') returns(bool) {
                                    
        /* Call Storage Contract */
        
        bool status = veggieCertificationStorage.setReceiverData(_batchNo,
                                                                 _transportInfo, 
                                                                 _quantity, 
                                                                 _shipName, 
                                                                 _shipNo, 
                                                                 _farmerName, 
                                                                 _farmAddress);
        
        emit DonePurchase(msg.sender, _batchNo);
        return (status);
    }

    function getInspectorData(address _batchNo) public view returns(uint256 arrivalDateTime) {
        /* Call Storage Contract */
        (arrivalDateTime) = veggieCertificationStorage.getInspectorData(_batchNo);  
        return (arrivalDateTime);
    }
    
    /* Perform Inspection */
    
    function updateInspectorData(address _batchNo,
                                 string _transportInfo,
                                 uint256 _quantity) public isValidPerformer(_batchNo, 'INSPECTOR') returns(bool) {
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setInspectorData(_batchNo,  
                                                                  _transportInfo, 
                                                                  _quantity);  
        
        emit DoneInspection(msg.sender, _batchNo);
        return (status);
    }
    
    /* Get Warehouse-In Data */
    
    function getWarehouseInData(address _batchNo) public view returns(uint256 stockNumber) {
        
        /* Call Storage Contract */
        (stockNumber) =  veggieCertificationStorage.getWarehouseInData(_batchNo);  
        return (stockNumber);
    }
    
    /* Perform Warehousing */
    
    function updateWarehouseInData(address _batchNo,
                                   uint256 _stockNumber) public isValidPerformer(_batchNo, 'WAREHOUSE') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setWarehouseInData(_batchNo, _stockNumber);  
        
        emit DoneEnterWarehouse(msg.sender, _batchNo);
        return (status);
    }
    
    function getNewBatchData(address _newBatchNo) public view returns(address batchNo1, 
                                                                      address batchNo2, 
                                                                      address batchNo3,
                                                                      uint256 bQuantity1,
                                                                      uint256 bQuantity2,
                                                                      uint256 bQuantity3) {
         
        /* Call Storage Contract */
        
        (batchNo1, 
         batchNo2, 
         batchNo3,
         bQuantity1,
         bQuantity2,
         bQuantity3) = veggieCertificationStorage. getNewBatchNo(_newBatchNo);  
         
        return (batchNo1, 
                batchNo2, 
                batchNo3,
                bQuantity1,
                bQuantity2,
                bQuantity3);
    }
    
    /* Generate New Batch Number */
    
    function addNewBatch(address _batchNo1, 
                         address _batchNo2, 
                         address _batchNo3,
                         uint256 _bQuantity1,
                         uint256 _bQuantity2,
                         uint256 _bQuantity3) public onlyOwner returns(address) {
        
        address newBatchNo = veggieCertificationStorage.setNewBatchNo(_batchNo1,
                                                                      _batchNo2,
                                                                      _batchNo3,
                                                                      _bQuantity1,
                                                                      _bQuantity2,
                                                                      _bQuantity3);
        
        emit DoneNewBatch(msg.sender, newBatchNo); 
        return (newBatchNo);
    }
    
    function getShippingData(address _newBatchNo) public view returns(uint256 quantity,
                                                                      string shipName, 
                                                                      string shipNumber, 
                                                                      string shipType, 
                                                                      string shippingAddress) {
         
        /* Call Storage Contract */
        
        (quantity,
         shipName, 
         shipNumber, 
         shipType, 
         shippingAddress) =  veggieCertificationStorage.getShippingData(_newBatchNo);  
         
        return (quantity,
                shipName, 
                shipNumber, 
                shipType, 
                shippingAddress);
    }
    
    /* Perform Shipping */
    
    function updateShippingData(address _newBatchNo,
                                uint256 quantity,
                                string shipName, 
                                string shipNumber, 
                                string shipType, 
                                string shippingAddress) public isValidPerformer(_newBatchNo, 'SHIPPING') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setShippingData(_newBatchNo, quantity, shipName, shipNumber, shipType,  shippingAddress);  
        
        emit DoneShipping(msg.sender, _newBatchNo);
        return (status);
    }
    
     function getSalesData(address _newBatchNo) public view returns (uint256 quantity,
                                                                     string  companyName,
                                                                     string  companyAddress,
                                                                     address salesman) {
        /* Call Storage Contract */
        (quantity,
         companyName,
         companyAddress,
         salesman) =  veggieCertificationStorage.getSalesData(_newBatchNo);  
        
        return (quantity,
                companyName,
                companyAddress,
                salesman);
    }
    
    /* Perform Sales */
    
    function updateSalesData(address _newBatchNo,
                             uint256 quantity,
                             string  companyName,
                             string  companyAddress,
                             address salesman) public isValidPerformer(_newBatchNo, 'SALES') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setSalesData(_newBatchNo, quantity, companyName, companyAddress, salesman);  
        
        emit DoneSales(msg.sender, _newBatchNo);
        return (status);
    }
    
}
