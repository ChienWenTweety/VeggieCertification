pragma solidity ^0.4.23;

import "./VeggieCertificationStorage.sol";
import "./Ownable.sol";

contract VeggieCertification is Ownable {
    
    event DonePurchase(address indexed user, address indexed batchNo);
    event DoneInspection(address indexed user, address indexed batchNo);
    event DoneReturn(address indexed user, address indexed batchNo);
    event DoneEnterWarehouse(address indexed user, address indexed batchNo);
    event DoneSales(address indexed user, address indexed batchNo);
    event DoneNewBatch(address indexed user, address indexed newBatchNo); 
    event DoneShipping(address indexed user, address indexed newBatchNo);
    event DoneReturnFromCustomers(address indexed user, address indexed newBatchNo);

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
    
    function getReturnData(address _batchNo) public view returns(uint256 _quantity,
                                                                 string  _memo) {
        
        (_quantity,
         _memo) = veggieCertificationStorage.getReturnData(_batchNo);  
        
        return (_quantity, _memo);
    }
    
    function returnGoods(address _batchNo,
                         uint256 _quantity,
                         string  _memo) public isValidPerformer(_batchNo, 'INSPECTOR') returns(bool) {
        
        bool status = veggieCertificationStorage.setReturnData(_batchNo,  
                                                               _quantity,
                                                               _memo);
                                                               
        emit DoneReturn(msg.sender, _batchNo);
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

    function getSalesData(address batchNo) public view returns (string  customerOrderNo,
                                                                uint256 quantity,
                                                                string  goodInfo,
                                                                string  companyName,
                                                                string  companyAddress,
                                                                address salesman) {
        /* Call Storage Contract */
        (customerOrderNo,
         quantity,
         goodInfo,
         companyName,
         companyAddress,
         salesman) = veggieCertificationStorage.getSalesData(batchNo);  
        
        return (customerOrderNo,
                quantity,
                goodInfo,
                companyName,
                companyAddress,
                salesman);
    }
    
    /* Perform Sales */
    
    function updateSalesData(address batchNo,
                             string  customerOrderNo,
                             uint256 quantity,
                             string  goodInfo,
                             string  companyName,
                             string  companyAddress,
                             address salesman) public isValidPerformer(batchNo, 'SALES') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setSalesData(batchNo, customerOrderNo, quantity, goodInfo, companyName, companyAddress, salesman);  
        
        emit DoneSales(msg.sender, batchNo);
        return (status);
    }

    function getNewBatchData(address _newBatchNo) public view returns(string  customerOrderNo,
                                                                      address batchNo1, 
                                                                      address batchNo2, 
                                                                      address batchNo3,
                                                                      uint256 bQuantity1,
                                                                      uint256 bQuantity2,
                                                                      uint256 bQuantity3) {
         
        /* Call Storage Contract */
        
        (customerOrderNo,
         batchNo1, 
         batchNo2, 
         batchNo3,
         bQuantity1,
         bQuantity2,
         bQuantity3) = veggieCertificationStorage. getNewBatchNo(_newBatchNo);  
         
        return (customerOrderNo,
                batchNo1, 
                batchNo2, 
                batchNo3,
                bQuantity1,
                bQuantity2,
                bQuantity3);
    }
    
    /* Generate New Batch Number */
    
    function addNewBatch(string  _customerOrderNo,
                         address _batchNo1, 
                         address _batchNo2, 
                         address _batchNo3,
                         uint256 _bQuantity1,
                         uint256 _bQuantity2,
                         uint256 _bQuantity3) public onlyOwner returns(address) {
        
        address newBatchNo = veggieCertificationStorage.setNewBatchNo(_customerOrderNo,
                                                                      _batchNo1,
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
    
    function updateShippingData(address newBatchNo,
                                uint256 quantity,
                                string shipName, 
                                string shipNumber, 
                                string shipType, 
                                string shippingAddress) public isValidPerformer(newBatchNo, 'SHIPPING') returns(bool) {
                                    
        /* Call Storage Contract */
        bool status = veggieCertificationStorage.setShippingData(newBatchNo, quantity, shipName, shipNumber, shipType,  shippingAddress);  
        
        emit DoneShipping(msg.sender, newBatchNo);
        return (status);
    }
    /*
    function getReturnGoodsData(address _newBatchNo) public view returns(uint256 quantity,
                                                                         string  memo) {
        
        (quantity,
         memo) = veggieCertificationStorage.getCustomerReturnData(_newBatchNo);  
        
        return (quantity, memo);
    }
    
    function returnGoodsFromCustomers(address newBatchNo,
                                      uint256 quantity,
                                      string  memo) public isValidPerformer(newBatchNo, 'SALES') returns(bool) {
        
        bool status = veggieCertificationStorage.setCustomerReturnData(newBatchNo,  
                                                                       quantity,
                                                                       memo);
                                                               
        emit DoneReturnFromCustomers(msg.sender, newBatchNo);
        return (status);                     
    }
    */
}
