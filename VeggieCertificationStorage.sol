pragma solidity ^0.4.23;

import "./VeggieCertificationStorageOwnable.sol";

contract VeggieCertificationStorage is VeggieCertificationStorageOwnable {
    
    address public lastAccess;
    
    constructor() public {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    /* Modifiers */ 
    modifier onlyAuthCaller() {
        lastAccess = msg.sender;
        require(authorizedCaller[msg.sender] == 1);
        _;
    }
    
    /* User Related */
    struct user {
        string name;
        string contactNo;
        bool isActive;
    } 
    
    mapping(address => user) userDetails;
    mapping(address => string) userRole;
    
    /* Caller Mapping */ 
    mapping(address => uint8) authorizedCaller;
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }

    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    /* User Roles: PURCHASE, INSPECTION, WAREHOUSE, SALES, SHIPPING */
    
    /* Process Related */
    struct basicDetails {
        string registrationNo;
        string companyName;
        string companyAddress;
    }

    struct Purchase {
        address batchNo;
        string transportInfo; 
        uint256 quantity;
        string shipName;
        string shipNo;
        string farmerName;
        string farmAddress;
        uint256 arrivalDateTime;
    }

    struct Inspection {
        address batchNo;
        string transportInfo;
        uint256 quantity;
        uint256 arrivalDateTime; 
    }
    
    struct Return {
        address batchNo;
        uint256 quantity;
        string  memo;
    }
    
    struct Warehouse {
        address batchNo; 
        uint256 stockNumber;
    }
    
    struct Sales {
        string  customerOrderNo;
        string  goodInfo;
        uint256 quantity;
        string  companyName;
        string  companyAddress;
        address salesman;
    }
    
    struct NewBatchDetails {
        string  customerOrderNo;
        address batchNo1; 
        address batchNo2;
        address batchNo3;
        uint256 bQuantity1;
        uint256 bQuantity2;
        uint256 bQuantity3;
    }
    
    struct Shipping {
        address newBatchNo; 
        uint256 quantity;
        string shipName; 
        string shipNo; 
        string shipType; 
        string shippingAddress;
    }
    /*
    struct CustomerReturn {
        address newBatchNo;
        uint256 quantity;
        string  memo;
    }
    */
    
    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => string) nextAction;
    mapping (address => Purchase) batchPurchase;
    mapping (address => Inspection) batchInspection;
    mapping (address => Return) batchReturn;
    mapping (address => Warehouse) batchWarehouse;
    mapping (string => Sales) batchSales;
    mapping (address => NewBatchDetails) newBatchDetails;
    mapping (address => Shipping) batchShipping;
    //mapping (address => CustomerReturn) batchCustomerReturn;
    
    
    /* Initialize struct pointer */
    user userDetail;
    basicDetails basicDetailsData;
    Purchase purchaseData;
    Inspection inspectionData;
    Return returnData;
    Warehouse warehouseData;
    Sales salesData;
    NewBatchDetails newBatchData;
    Shipping shippingData;
    //CustomerReturn CustomerReturnData;
    
    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller view returns(string) {
        return userRole[_userAddress];
    }
    
    /* Get Next Action */    
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string) {
        return nextAction[_batchNo];
    }
        
    /*set user details*/
    function setUser(address _userAddress,
                     string  _name, 
                     string  _contactNo, 
                     string  _role, 
                     bool    _isActive) public onlyAuthCaller returns(bool) {
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address userAddress) public onlyAuthCaller view returns(string name, 
                                                                             string contactNo, 
                                                                             string role,
                                                                             bool   isActive) {

        /*Getting value from struct*/
        user memory tmpData = userDetails[userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[userAddress], tmpData.isActive);
    }
    
    /*set batch basicDetails*/
    function setBasicDetails(string _registrationNo,
                             string _companyName,
                             string _companyAddress) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(msg.sender, now));
        address _batchNo = address (tmpData);
        
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.companyName = _companyName;
        basicDetailsData.companyAddress = _companyAddress;
       
        batchBasicDetails[_batchNo] = basicDetailsData;
        nextAction[_batchNo] = 'PURCHASE';   
        return _batchNo;
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(address batchNo) public onlyAuthCaller view returns(string registrationNo,
                                                                                 string companyName,
                                                                                 string companyAddress) {
        
        basicDetails memory tmpData = batchBasicDetails[batchNo];
        
        return (tmpData.registrationNo, tmpData.companyName, tmpData.companyAddress);
    }
    
    /*set Purchase data*/ //
    function setPurchaseData(address _batchNo,
                             string  _transportInfo,
                             uint256 _quantity, 
                             string  _shipName,
                             string  _shipNo,
                             string  _farmerName,
                             string  _farmAddress) public onlyAuthCaller returns(bool) {
                             
        purchaseData.transportInfo = _transportInfo;
        purchaseData.quantity = _quantity;
        purchaseData.shipName = _shipName;
        purchaseData.shipNo = _shipNo;
        purchaseData.farmerName = _farmerName;
        purchaseData.farmAddress = _farmAddress;
        purchaseData.arrivalDateTime = now;
        
        batchPurchase[_batchNo] = purchaseData;
        nextAction[_batchNo] = 'INSPECTION'; 
        return true;
    }
    
    /*get Purchase data*/ //
    function getPurchaseData(address batchNo) public onlyAuthCaller view returns(string  transportInfo,
                                                                                 uint256 quantity,
                                                                                 string  shipName,
                                                                                 string  shipNo,
                                                                                 string  farmerName,
                                                                                 string  farmAddress,
                                                                                 uint256 arrivalDateTime) {
                                                                                        
        Purchase memory tmpData = batchPurchase[batchNo];
        
        return (tmpData.transportInfo,
                tmpData.quantity, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.farmerName,
                tmpData.farmAddress,
                tmpData.arrivalDateTime);
    }

    /*set Inspection data*/
    function setInspectionData(address _batchNo, 
                              string  _transportInfo,
                              uint256 _quantity) public onlyAuthCaller returns(bool) {
        
        inspectionData.batchNo = _batchNo;
        inspectionData.transportInfo = _transportInfo;
        inspectionData.quantity = _quantity;
        inspectionData.arrivalDateTime = now;
        
        batchInspection[_batchNo] = inspectionData;
        nextAction[_batchNo] = 'WAREHOUSE'; 
        return true;
    }
    
    /*get Inspactor data*/
    function getInspectionData(address batchNo) public onlyAuthCaller view returns (uint256 arrivalDateTime) {
        
        Inspection memory tmpData = batchInspection[batchNo];
        return (tmpData.arrivalDateTime);
    }
    
    function setReturnData(address _batchNo,  
                           uint256 _quantity,
                           string  _memo) public onlyAuthCaller returns(bool) {
        
        returnData.quantity = _quantity;
        returnData.memo = _memo;
        
        batchReturn[_batchNo] = returnData;
        return true;
    }
    
    function getReturnData(address batchNo) public onlyAuthCaller view returns (uint256 quantity,
                                                                                string  memo) {
        
        Return memory tmpData = batchReturn[batchNo];
        
        return (tmpData.quantity,
                tmpData.memo);
    }
    
    /*set Warehouse-in data*/
    function setWarehouseInData(address _batchNo, 
                                uint256 _stockNumber) public onlyAuthCaller returns(bool) {
        
        warehouseData.stockNumber = _stockNumber;
        
        batchWarehouse[_batchNo] = warehouseData;
        nextAction[_batchNo] = 'SALES'; 
        return true;
    }
    
    /*get warehouse-in data*/ 
    function getWarehouseInData(address batchNo) public onlyAuthCaller view returns(uint256 stockNumber) {

        Warehouse memory tmpData = batchWarehouse[batchNo];
        
        return (tmpData.stockNumber);
    }
    
    function setSalesData(string  _customerOrderNo,
                          string  _goodInfo,
                          uint256 _quantity,
                          string  _companyName,
                          string  _companyAddress,
                          address _salesman) public onlyAuthCaller returns(bool) {
                             
        salesData.goodInfo = _goodInfo;
        salesData.quantity = _quantity;
        salesData.companyName = _companyName;
        salesData.companyAddress = _companyAddress;
        salesData.salesman = _salesman;
        
        batchSales[_customerOrderNo] = salesData;
        return true;
    }
    
    function getSalesData(string customerOrderNo) public onlyAuthCaller view returns(string  goodInfo,
                                                                                     uint256 quantity,
                                                                                     string  companyName,
                                                                                     string  companyAddress,
                                                                                     address salesman) {
                                                                                        
        Sales memory tmpData = batchSales[customerOrderNo];
        
        return (tmpData.goodInfo,
                tmpData.quantity,
                tmpData.companyName,
                tmpData.companyAddress, 
                tmpData.salesman);
    }
    
    function setNewBatchNo(string  _customerOrderNo,
                           address _batchNo1, 
                           address _batchNo2, 
                           address _batchNo3,
                           uint256 _bQuantity1,
                           uint256 _bQuantity2,
                           uint256 _bQuantity3) public onlyAuthCaller returns(address) {
                                 
        uint tmpData = uint(keccak256(msg.sender, now));
        address _newBatchNo = address (tmpData);
        
        newBatchData.customerOrderNo = _customerOrderNo;
        newBatchData.batchNo1 = _batchNo1;
        newBatchData.batchNo2 = _batchNo2;
        newBatchData.batchNo3 = _batchNo3;
        newBatchData.bQuantity1 = _bQuantity1;
        newBatchData.bQuantity2 = _bQuantity2;
        newBatchData.bQuantity3 = _bQuantity3;

        newBatchDetails[_newBatchNo] = newBatchData;
        nextAction[_newBatchNo] = 'SHIPPING';
        return _newBatchNo;
    }
    
    function getNewBatchNo(address newBatchNo) public onlyAuthCaller view returns(string  customerOrderNo,
                                                                                  address batchNo1,
                                                                                  uint256 bQuantity1, 
                                                                                  address batchNo2,
                                                                                  uint256 bQuantity2, 
                                                                                  address batchNo3,
                                                                                  uint256 bQuantity3) {
                                                                                        
        NewBatchDetails memory tmpData = newBatchDetails[newBatchNo];
        
        return (tmpData.customerOrderNo,
                tmpData.batchNo1,
                tmpData.bQuantity1,
                tmpData.batchNo2,
                tmpData.bQuantity2,
                tmpData.batchNo3,
                tmpData.bQuantity3);
    }
    
    function setShippingData(address _newBatchNo,
                             uint256 _quantity,
                             string  _shipName, 
                             string  _shipNo, 
                             string  _shipType, 
                             string  _shippingAddress) public onlyAuthCaller returns(bool) {
                             
        shippingData.quantity = _quantity;
        shippingData.shipName = _shipName;
        shippingData.shipNo = _shipNo;
        shippingData.shipType = _shipType;
        shippingData.shippingAddress = _shippingAddress;
        
        batchShipping[_newBatchNo] = shippingData;
        nextAction[_newBatchNo] = 'END'; 
        return true;
    }
  
    function getShippingData(address newBatchNo) public onlyAuthCaller view returns(uint256 quantity,
                                                                                    string  shipName,
                                                                                    string  shipNumber, 
                                                                                    string  shipType, 
                                                                                    string  shippingAddress) {
                                                                                        
        Shipping memory tmpData = batchShipping[newBatchNo];
        
        return (tmpData.quantity,
                tmpData.shipName,
                tmpData.shipNo, 
                tmpData.shipType, 
                tmpData.shippingAddress);
    }
    /*
    function setCustomerReturnData(address _newBatchNo,  
                                   uint256 _quantity,
                                   string  _memo) public onlyAuthCaller returns(bool) {
        
        CustomerReturnData.quantity = _quantity;
        CustomerReturnData.memo = _memo;
        
        batchCustomerReturn[_newBatchNo] = CustomerReturnData;
        return true;
    }
    
    function getCustomerReturnData(address newBatchNo) public onlyAuthCaller view returns (uint256 quantity,
                                                                                           string  memo) {
        
        CustomerReturn memory tmpData = batchCustomerReturn[newBatchNo];
        
        return (tmpData.quantity,
                tmpData.memo);
    }
    */
}
