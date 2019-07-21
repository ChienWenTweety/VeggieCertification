pragma solidity ^0.4.23;

import "./VeggieCertificationStorageOwnable.sol";

contract VeggieCertificationStorage is VeggieCertificationStorageOwnable {
    
    //address public lastAccess;//
    constructor()  public payable {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }
    
    /* Events */
    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);
    
    
    /* Modifiers*/ 
    
    modifier onlyAuthCaller(){
        /*lastAccess = msg.sender;
        require(authorizedCaller[msg.sender] == 1);*/
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
    
    /* authorize caller 
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 1;
        emit AuthorizedCaller(_caller);
        return true;
    }

    /* deauthorize caller 
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    */
    
    /* User Roles: RECEIVER,
                   INSPECTOR,
                   WAREHOUSE,
                   OUTOFWAREHOUSE
    */
    
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
        uint256 arrivalDateTime; 
        string transportInfo; 
        uint256 quantity;
    }
    
    struct WarehouseManager {
        address batchNo; 
        uint256 stockNumber;
    }
    
    struct Carrier {
        address batchNo; 
        string shipName;
        string shipNo;
        string shipType;
        uint256 quantity;
    }
    
    struct NewBatchDetails {
        address batchNo1; 
        address batchNo2;
        address batchNo3;
        uint256 bQuantity1;
        uint256 bQuantity2;
        uint256 bQuantity3;
    }
    
    mapping (address => basicDetails) batchBasicDetails;
    mapping (address => Receiver) batchReceiver;
    mapping (address => Inspector) batchInspector;
    mapping (address => WarehouseManager) batchwarehouseManager;
    mapping (address => Carrier) batchCarrier;
    mapping (address => string) nextAction;
    mapping (address => NewBatchDetails) newBatchDetails;
    
    /*Initialize struct pointer*/
    user userDetail;
    basicDetails basicDetailsData;
    Receiver receiverData;
    Inspector inspectorData;
    WarehouseManager warehouseManagerData;
    Carrier carrier;
    NewBatchDetails newBatchData;
     
    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller view returns(string) {
        return userRole[_userAddress];
    }
    
    /* Get Next Action  */    
    function getNextAction(address _batchNo) public onlyAuthCaller view returns(string) {
        return nextAction[_batchNo];
    }
        
    /*set user details*/
    function setUser(address _userAddress,
                     string _name, 
                     string _contactNo, 
                     string _role, 
                     bool _isActive) public onlyAuthCaller returns(bool) {
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        //userDetail.profileHash = _profileHash;//
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address _userAddress) public onlyAuthCaller view returns(string name, 
                                                                              string contactNo, 
                                                                              string role,
                                                                              bool isActive, 
                                                                              string profileHash) {

        /*Getting value from struct*/
        user memory tmpData = userDetails[_userAddress];
        
        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive, tmpData.profileHash);
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(address _batchNo) public onlyAuthCaller view returns(string registrationNo,
                                                                                  string companyName,
                                                                                  string companyAddress) {
        
        basicDetails memory tmpData = batchBasicDetails[_batchNo];
        
        return (tmpData.registrationNo,tmpData.companyName,tmpData.companyAddress);
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

    /*set Importer data*/
    function setReceiverData(address _batchNo,
                             string _transportInfo,
                             uint256 _quantity, 
                             string _shipName,
                             string _shipNo,
                             string _farmerName,
                             string _farmAddress) public onlyAuthCaller returns(bool) {
                             
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
    
    /*get Importer data*/
    function getReceiverData(address batchNo) public onlyAuthCaller view returns(string transportInfo,
                                                                                 uint256 quantity,
                                                                                 string shipName,
                                                                                 string shipNo,
                                                                                 uint256 arrivalDateTime,
                                                                                 string farmerName,
                                                                                 string farmAddress) {
                                                                                        
        
        Receiver memory tmpData = batchReceiver[batchNo];
        
        
        return (tmpData.transportInfo,
                tmpData.quantity, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.arrivalDateTime, 
                tmpData.farmerName,
                tmpData.farmAddress);
    }

    
    /*set farm Inspector data*/
    function setInspectorData(address _batchNo, 
                              string _transportInfo,
                              uint256 _quantity) public onlyAuthCaller returns(bool) {
        
        inspectorData.batchNo = _batchNo;
        inspectorData.arrivalDateTime = now;
        inspectorData.transportInfo = _transportInfo;
        inspectorData.quantity = _quantity;
        
        batchInspector[_batchNo] = inspectorData;
        nextAction[_batchNo] = 'WAREHOUSE'; 
        return true;
    }
    
    /*get inspactor data*/
    function getInspectorData(address batchNo) public onlyAuthCaller view returns (uint256 arrivalDateTime) {
        
        Inspector memory tmpData = batchInspector[batchNo];
        return (tmpData.arrivalDateTime);
    }
    
    /*set warehouseManager data*/
    function setWarehouseInData(address _batchNo, 
                                uint256 _stockNumber) public onlyAuthCaller returns(bool) {
        
        warehouseManagerData.stockNumber = _stockNumber;
        
        batchwarehouseManager[_batchNo] = warehouseManagerData;
        nextAction[_batchNo] = 'SHIPPING'; 
        return true;
    }
    
    
    /*get Processor data*/ 
    function getWarehouseInData(address _batchNo) public onlyAuthCaller view returns(uint256 stockNumber) {

        WarehouseManager memory tmpData = batchwarehouseManager[_batchNo];
        
        return (tmpData.stockNumber);
    }
    
    function setNewBatchNo(address _batchNo1, 
                           address _batchNo2, 
                           address _batchNo3,
                           uint256 _bQuantity1,
                           uint256 _bQuantity2,
                           uint256 _bQuantity3) public returns(address) {
                                 
        uint tmpData = uint(keccak256(msg.sender, now));
        address _newBatchNo = address (tmpData);
        
        newBatchData.batchNo1 = _batchNo1;
        newBatchData.bQuantity1 = _bQuantity1;
        newBatchData.batchNo2 = _batchNo2;
        newBatchData.bQuantity2 = _bQuantity2;
        newBatchData.batchNo3 = _batchNo3;
        newBatchData.bQuantity3 = _bQuantity3;

        newBatchDetails[_newBatchNo] = newBatchData;
        return _newBatchNo;
    }
  
} 
