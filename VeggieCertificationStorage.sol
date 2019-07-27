pragma solidity ^0.4.23;

import "./VeggieCertificationStorageOwnable.sol";

contract VeggieCertificationStorage is VeggieCertificationStorageOwnable {
    
    address public lastAccess;
    
    constructor()  public {
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
        string profileHash;
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
    
    /* User Roles: RECEIVER, INSPECTOR, WAREHOUSE, SALES, SHIPPING */
    
    /* Process Related */
    struct basicDetails {
        string registrationNo;
        string companyName;
        string companyAddress;
    }

    struct Receiver {
        address batchNo;
        string transportInfo; 
        uint256 arrivalDateTime; 
        uint256 quantity;
        string shipName;
        string shipNo;
        string farmerName;
        string farmAddress;
    }

    struct Inspector {
        address batchNo;
        string transportInfo;
        uint256 arrivalDateTime; 
        uint256 quantity;
    }
    
    struct Return {
        address batchNo;
        uint256 quantity;
        string  memo;
    }
    
    struct WarehouseManager {
        address batchNo; 
        uint256 stockNumber;
    }
    
    struct Sales {
        address batchNo;
        string  customerOrderNo;
        uint256 quantity;
        string  goodInfo;
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
    
    struct CustomerReturn {
        address newBatchNo;
        uint256 quantity;
        string  memo;
    }
    
    
    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => Receiver) batchReceiver;
    mapping (address => Inspector) batchInspector;
    mapping (address => Return) batchReturn;
    mapping (address => WarehouseManager) batchWarehouseManager;
    mapping (address => string) nextAction;
    mapping (address => Sales) batchSales;
    mapping (address => NewBatchDetails) newBatchDetails;
    mapping (address => Shipping) batchShipping;
    mapping (address => CustomerReturn) batchCustomerReturn;
    
    
    /* Initialize struct pointer */
    user userDetail;
    basicDetails basicDetailsData;
    Receiver receiverData;
    Inspector inspectorData;
    Return returnData;
    WarehouseManager warehouseManagerData;
    Sales salesData;
    NewBatchDetails newBatchData;
    Shipping shippingData;
    CustomerReturn CustomerReturnData;
    
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
        //userDetail.profileHash = _profileHash;
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address userAddress) public onlyAuthCaller view returns(string name, 
                                                                             string contactNo, 
                                                                             string role,
                                                                             bool   isActive, 
                                                                             string profileHash) {

        /*Getting value from struct*/
        user memory tmpData = userDetails[userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[userAddress], tmpData.isActive, tmpData.profileHash);
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
        nextAction[_batchNo] = 'RECEIVER';   
        return _batchNo;
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(address batchNo) public onlyAuthCaller view returns(string registrationNo,
                                                                                 string companyName,
                                                                                 string companyAddress) {
        
        basicDetails memory tmpData = batchBasicDetails[batchNo];
        
        return (tmpData.registrationNo, tmpData.companyName, tmpData.companyAddress);
    }
    
    /*set Receiver data*/
    function setReceiverData(address _batchNo,
                             string  _transportInfo,
                             uint256 _quantity, 
                             string  _shipName,
                             string  _shipNo,
                             string  _farmerName,
                             string  _farmAddress) public onlyAuthCaller returns(bool) {
                             
        receiverData.transportInfo = _transportInfo;
        receiverData.quantity = _quantity;
        receiverData.shipName = _shipName;
        receiverData.shipNo = _shipNo;
        receiverData.arrivalDateTime = now;
        receiverData.farmerName = _farmerName;
        receiverData.farmAddress = _farmAddress;
        
        batchReceiver[_batchNo] = receiverData;
        nextAction[_batchNo] = 'INSPECTOR'; 
        return true;
    }
    
    /*get Receiver data*/
    function getReceiverData(address batchNo) public onlyAuthCaller view returns(string  transportInfo,
                                                                                 uint256 quantity,
                                                                                 string  shipName,
                                                                                 string  shipNo,
                                                                                 uint256 arrivalDateTime,
                                                                                 string  farmerName,
                                                                                 string  farmAddress) {
                                                                                        
        
        Receiver memory tmpData = batchReceiver[batchNo];
        
        return (tmpData.transportInfo,
                tmpData.quantity, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.arrivalDateTime, 
                tmpData.farmerName,
                tmpData.farmAddress);
    }

    /*set Inspector data*/
    function setInspectorData(address _batchNo, 
                              string  _transportInfo,
                              uint256 _quantity) public onlyAuthCaller returns(bool) {
        
        inspectorData.batchNo = _batchNo;
        inspectorData.arrivalDateTime = now;
        inspectorData.transportInfo = _transportInfo;
        inspectorData.quantity = _quantity;
        
        batchInspector[_batchNo] = inspectorData;
        nextAction[_batchNo] = 'WAREHOUSE'; 
        return true;
    }
    
    /*get Inspactor data*/
    function getInspectorData(address batchNo) public onlyAuthCaller view returns (uint256 arrivalDateTime) {
        
        Inspector memory tmpData = batchInspector[batchNo];
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
        
        warehouseManagerData.stockNumber = _stockNumber;
        
        batchWarehouseManager[_batchNo] = warehouseManagerData;
        nextAction[_batchNo] = 'SALES'; 
        return true;
    }
    
    /*get warehouse-in data*/ 
    function getWarehouseInData(address batchNo) public onlyAuthCaller view returns(uint256 stockNumber) {

        WarehouseManager memory tmpData = batchWarehouseManager[batchNo];
        
        return (tmpData.stockNumber);
    }
    
    function setSalesData(address _batchNo,
                          string  _customerOrderNo,
                          uint256 _quantity,
                          string  _goodInfo,
                          string  _companyName,
                          string  _companyAddress,
                          address _salesman) public onlyAuthCaller returns(bool) {
                             
        salesData.customerOrderNo = _customerOrderNo;
        salesData.quantity = _quantity;
        salesData.goodInfo = _goodInfo;
        salesData.companyName = _companyName;
        salesData.companyAddress = _companyAddress;
        salesData.salesman = _salesman;
        
        batchSales[_batchNo] = salesData;
        return true;
    }
    
    function getSalesData(address batchNo) public onlyAuthCaller view returns(string  customerOrderNo,
                                                                              uint256 quantity,
                                                                              string  goodInfo,
                                                                              string  companyName,
                                                                              string  companyAddress,
                                                                              address salesman) {
                                                                                        
        
        Sales memory tmpData = batchSales[batchNo];
        
        return (tmpData.customerOrderNo,
                tmpData.quantity,
                tmpData.goodInfo,
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
        newBatchData.bQuantity1 = _bQuantity1;
        newBatchData.batchNo2 = _batchNo2;
        newBatchData.bQuantity2 = _bQuantity2;
        newBatchData.batchNo3 = _batchNo3;
        newBatchData.bQuantity3 = _bQuantity3;

        newBatchDetails[_newBatchNo] = newBatchData;
        nextAction[_newBatchNo] = 'SHIPPING';
        return _newBatchNo;
    }
    
    function getNewBatchNo(address newBatchNo) public onlyAuthCaller view returns(string  customerOrderNo,
                                                                                  address batchNo1, 
                                                                                  address batchNo2, 
                                                                                  address batchNo3,
                                                                                  uint256 bQuantity1,
                                                                                  uint256 bQuantity2,
                                                                                  uint256 bQuantity3) {
                                                                                        
        
        NewBatchDetails memory tmpData = newBatchDetails[newBatchNo];
        
        return (tmpData.customerOrderNo,
                tmpData.batchNo1,
                tmpData.batchNo2,
                tmpData.batchNo3,
                tmpData.bQuantity1, 
                tmpData.bQuantity2, 
                tmpData.bQuantity3);
    }
    
    function setShippingData(address _newBatchNo,
                             uint256 _quantity,
                             string  _shipName, 
                             string  _shipNo, 
                             string  _shipType, 
                             string  _shippingAddress) public onlyAuthCaller returns(bool) {
                             
        shippingData.shipName = _shipName;
        shippingData.quantity = _quantity;
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
