pragma solidity ^0.4.23;

import "./VeggieSupplyChainStorageOwnable.sol";

contract VeggieSupplyChainStorage is VeggieSupplyChainStorageOwnable {
    
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
    
    /* User Departments: PURCHASE, INSPECTION, WAREHOUSE, SALES, SHIPPING */
    
    /* User Related */
    struct user {
        string name;
        string contactNo;
        bool isActive;
    } 
    
    mapping(address => user) userDetails;
    mapping(address => string) userDept;
    
    /* Process Related */
    struct BasicDetails {
        string goodsInfo;
        uint256 quantity;
        string farmerName;
        string farmAddress;
        uint256 shippingDate;
    }

    struct Purchase {
        string goodsInfo; 
        uint256 quantity;
        address consignee;
        uint256 arrivalDateTime;
    }

    struct Inspection {
        string goodsInfo;
        uint256 quantity;
        address inspector;
        uint256 inspectionDateTime;
    }
    
    struct GoodsReturn {
        string  memo;
        uint256 quantity;
        address inspector;
        uint256 returnDateTime;
    }
    
    struct Warehouse {
        string stockNo;
        uint256 quantity;
        address warehouseOfficer;
        uint256 stockDateTime;
    }
    
    struct Sales {
        string  goodsInfo;
        uint256 quantity;
        string  company;
        address salesman;
        uint256 salesDateTime;
    }
    
    struct NewBatchDetails {
        string  customerOrderNo;
        address batch1; 
        address batch2;
        address batch3;
        uint256 bQuantity1;
        uint256 bQuantity2;
        uint256 bQuantity3;
    }
    
    struct Shipping { 
        uint256 quantity;
        string shipTruckNo; 
        string shipType; 
        string shipAddress;
        address consignor;
        uint256 shippingDateTime;
    }
    
    mapping (address => BasicDetails) basicDetails;
    mapping (address => string) nextAction;
    mapping (address => Purchase) purchase;
    mapping (address => Inspection) inspection;
    mapping (address => GoodsReturn) goodsReturn;
    mapping (address => Warehouse) warehouse;
    mapping (string => Sales) sales;
    mapping (address => NewBatchDetails) newBatchDetails;
    mapping (address => Shipping) shipping;
    
    /* Initialize struct pointer */
    user userDetail;
    BasicDetails basicDetailsData;
    Purchase purchaseData;
    Inspection inspectionData;
    GoodsReturn returnData;
    Warehouse warehouseData;
    Sales salesData;
    NewBatchDetails newBatchData;
    Shipping shippingData;
    
    /* Get User Dept */
    function getUserDept(address _address) public onlyAuthCaller view returns(string) {
        return userDept[_address];
    }
    
    /* Get Next Action */    
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string) {
        return nextAction[_batchNo];
    }
        
    /* set user details */
    function setUser(address _address,
                     string  _name, 
                     string  _contactNo, 
                     string  _dept, 
                     bool    _isActive) public onlyAuthCaller returns(bool) {
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        
        /*store data into mapping*/
        userDetails[_address] = userDetail;
        userDept[_address] = _dept;
        return true;
    }  
    
    /* get user details */
    function getUser(address _address) public onlyAuthCaller view returns(string, 
                                                                          string, 
                                                                          string,
                                                                          bool) {
        
        /*Getting value from struct*/
        user memory tmpData = userDetails[_address];
        
        return (tmpData.name, 
                tmpData.contactNo, 
                userDept[_address], 
                tmpData.isActive);
    }
    
    /* set batch basicDetails */
    function setBasicDetails(string  _goodsInfo,
                             uint256 _quantity,
                             string  _farmerName,
                             string  _farmAddress,
                             uint256 _shippingDate) public onlyAuthCaller returns(address) {
        
        uint tmpData = uint(keccak256(msg.sender, now));
        address _batchNo = address (tmpData);
        
        basicDetailsData.goodsInfo = _goodsInfo;
        basicDetailsData.quantity = _quantity;
        basicDetailsData.farmerName = _farmerName;
        basicDetailsData.farmAddress = _farmAddress;
        basicDetailsData.shippingDate = _shippingDate;
       
        basicDetails[_batchNo] = basicDetailsData;
        nextAction[_batchNo] = 'PURCHASE';   
        return _batchNo;
    }
    
    /* get batch basicDetails */
    function getBasicDetails(address _batchNo) public onlyAuthCaller view returns(string,
                                                                                  uint256,
                                                                                  string,
                                                                                  string,
                                                                                  uint256) {
        
        BasicDetails memory tmpData = basicDetails[_batchNo];
        
        return (tmpData.goodsInfo, 
                tmpData.quantity, 
                tmpData.farmerName,
                tmpData.farmAddress,
                tmpData.shippingDate);
    }
    
    /* set Purchase data */ 
    function setPurchaseData(address _batchNo,
                             string  _goodsInfo, 
                             uint256 _quantity,
                             address _consignee) public onlyAuthCaller returns(bool) {
                             
        purchaseData.goodsInfo = _goodsInfo;
        purchaseData.quantity = _quantity;
        purchaseData.consignee = _consignee;
        purchaseData.arrivalDateTime = now;
        
        purchase[_batchNo] = purchaseData;
        nextAction[_batchNo] = 'INSPECTION'; 
        return true;
    }
    
    /* get Purchase data */ 
    function getPurchaseData(address _batchNo) public onlyAuthCaller view returns(string,
                                                                                  uint256,
                                                                                  address,
                                                                                  uint256) {
                                                                                        
        Purchase memory tmpData = purchase[_batchNo];
        
        return (tmpData.goodsInfo,
                tmpData.quantity,
                tmpData.consignee,
                tmpData.arrivalDateTime);
    }

    /* set Inspection data */
    function setInspectionData(address _batchNo,
                               string  _goodsInfo,
                               uint256 _quantity,
                               address _inspector) public onlyAuthCaller returns(bool) {
        
        inspectionData.goodsInfo = _goodsInfo;
        inspectionData.quantity = _quantity;
        inspectionData.inspector = _inspector;
        inspectionData.inspectionDateTime = now;
        
        inspection[_batchNo] = inspectionData;
        nextAction[_batchNo] = 'WAREHOUSE'; 
        return true;
    }
    
    /* get Inspection data */
    function getInspectionData(address _batchNo) public onlyAuthCaller view returns (string,
                                                                                     uint256,
                                                                                     address,
                                                                                     uint256) {
        
        Inspection memory tmpData = inspection[_batchNo];
        
        return (tmpData.goodsInfo,
                tmpData.quantity,
                tmpData.inspector,    
                tmpData.inspectionDateTime);
    }
 
    function setReturnData(address _batchNo,
                           string  _memo,
                           uint256 _quantity,
                           address _inspector) public onlyAuthCaller returns(bool) {
        
        returnData.memo = _memo;
        returnData.quantity = _quantity;
        returnData.inspector = _inspector;
        returnData.returnDateTime = now;
        
        goodsReturn[_batchNo] = returnData;
        return true;
    }
    
    function getReturnData(address _batchNo) public onlyAuthCaller view returns (string,
                                                                                 uint256,
                                                                                 address,
                                                                                 uint256) {
        
        GoodsReturn memory tmpData = goodsReturn[_batchNo];
        
        return (tmpData.memo,
                tmpData.quantity,
                tmpData.inspector,
                tmpData.returnDateTime);
    }
    
    /* set warehouse-in data */
    function setWarehouseData(address _batchNo, 
                              string _stockNo,
                              uint256 _quantity,
                              address _warehouseOfficer) public onlyAuthCaller returns(bool) {
        
        warehouseData.stockNo = _stockNo;
        warehouseData.quantity = _quantity;
        warehouseData.warehouseOfficer = _warehouseOfficer;
        warehouseData.stockDateTime = now;
        
        warehouse[_batchNo] = warehouseData;
        nextAction[_batchNo] = 'SALES'; 
        return true;
    }
    
    /* get warehouse-in data */ 
    function getWarehouseData(address _batchNo) public onlyAuthCaller view returns(string,
                                                                                   uint256,
                                                                                   address,
                                                                                   uint256) {

        Warehouse memory tmpData = warehouse[_batchNo];
        
        return (tmpData.stockNo,
                tmpData.quantity,
                tmpData.warehouseOfficer,
                tmpData.stockDateTime);
    }
    
    function setSalesData(string  _customerOrderNo,
                          string  _goodsInfo,
                          uint256 _quantity,
                          string  _company,
                          address _salesman) public onlyAuthCaller returns(bool) {
                             
        salesData.goodsInfo = _goodsInfo;
        salesData.quantity = _quantity;
        salesData.company = _company;
        salesData.salesman = _salesman;
        salesData.salesDateTime = now;
        
        sales[_customerOrderNo] = salesData;
        return true;
    }
    
    function getSalesData(string _customerOrderNo) public onlyAuthCaller view returns(string,
                                                                                      uint256,
                                                                                      string,
                                                                                      address,
                                                                                      uint256) {
                                                                                        
        Sales memory tmpData = sales[_customerOrderNo];
        
        return (tmpData.goodsInfo,
                tmpData.quantity,
                tmpData.company,
                tmpData.salesman,
                tmpData.salesDateTime);
    }
    
    function setNewBatchNo(string  _customerOrderNo,
                           address _batch1,
                           uint256 _bQTY1, 
                           address _batch2,
                           uint256 _bQTY2, 
                           address _batch3,
                           uint256 _bQTY3) public onlyAuthCaller returns(address) {
                                 
        uint tmpData = uint(keccak256(msg.sender, now));
        address _newBatchNo = address (tmpData);
        
        newBatchData.customerOrderNo = _customerOrderNo;
        newBatchData.batch1 = _batch1;
        newBatchData.bQuantity1 = _bQTY1;
        newBatchData.batch2 = _batch2;
        newBatchData.bQuantity2 = _bQTY2;
        newBatchData.batch3 = _batch3;
        newBatchData.bQuantity3 = _bQTY3;

        newBatchDetails[_newBatchNo] = newBatchData;
        nextAction[_newBatchNo] = 'SHIPPING';
        return _newBatchNo;
    }
    
    function getNewBatchNo(address _newBatchNo) public onlyAuthCaller view returns(string,
                                                                                   address,
                                                                                   uint256, 
                                                                                   address,
                                                                                   uint256, 
                                                                                   address,
                                                                                   uint256) {
                                                                                        
        NewBatchDetails memory tmpData = newBatchDetails[_newBatchNo];
        
        return (tmpData.customerOrderNo,
                tmpData.batch1,
                tmpData.bQuantity1,
                tmpData.batch2,
                tmpData.bQuantity2,
                tmpData.batch3,
                tmpData.bQuantity3);
    }
    
    function setShippingData(address _newBatchNo,
                             uint256 _quantity,
                             string  _truckNo, 
                             string  _type,
                             string  _address,
                             address _consignor) public onlyAuthCaller returns(bool) {
                             
        shippingData.quantity = _quantity;
        shippingData.shipTruckNo = _truckNo;
        shippingData.shipType = _type;
        shippingData.shipAddress = _address;
        shippingData.consignor = _consignor;
        shippingData.shippingDateTime = now;
        
        shipping[_newBatchNo] = shippingData;
        nextAction[_newBatchNo] = 'END'; 
        return true;
    }
    
    function getShippingData(address _newBatchNo) public onlyAuthCaller view returns(uint256,
                                                                                     string,
                                                                                     string,
                                                                                     string,
                                                                                     address,
                                                                                     uint256) {
                                                                                        
        Shipping memory tmpData = shipping[_newBatchNo];
        
        return (tmpData.quantity,
                tmpData.shipTruckNo, 
                tmpData.shipType, 
                tmpData.shipAddress,
                tmpData.consignor,
                tmpData.shippingDateTime);
    }
}
