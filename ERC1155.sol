pragma solidity ^0.8.4;


interface ERC1155Interface 
{
     event TransferSingle(address  _operator, address  _from, address  _to, uint256 _id, uint256 _value);
     event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
     event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
     
     
     //Functions
      function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) external;
      function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values) external;
      function balanceOf(address _owner, uint256 _tokenId) external view returns (uint256);
      function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);
      function setApprovalForAll(address _operator, bool _approved) external;
      function isApprovedForAll(address _owner, address _operator) external view returns (bool);


 
}

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) 
    {
        require(b <= a,"Less Funds"); 
        c = a - b; 
        
    } 
    function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } 
    function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}


contract ShahbazToken is  ERC1155Interface , SafeMath
{
    //mapping for owner's blance
    mapping(uint => mapping(address => uint )) balances;
    
    //maping  for the operators who're approved
    mapping(address => mapping(address => bool)) private allowed;
    
     function balanceOf(address _owner, uint256 _tokenId) override external view returns (uint tokens)
     {
         return tokens = balances[_tokenId][_owner];
     }
     
     function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) override external view returns (uint256[] memory)
     {
     
        require(_owners.length == _ids.length);
        uint256[] memory ownerBalances = new uint256[](_owners.length);
        for(uint256 i=0 ;  i< _owners.length ; i++)
        {
            ownerBalances[i] = balances[_ids[i]][_owners[i]];
        }
        return ownerBalances;
     }
     
      function setApprovalForAll(address _operator, bool _approved) override external
      {
          require(_operator != msg.sender , "Enter Other Address For Approval");
          allowed[msg.sender][_operator] = _approved;
          emit ApprovalForAll(msg.sender , _operator ,_approved);
          
      }
      
      function isApprovedForAll(address _owner, address _operator) override external view returns (bool)
      {
          return allowed[_owner][_operator];
      }
      
      function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) override external
      {
          require(_to != address(0),"Enter The Valid Address");
        //   bool authorized = allowed[realOwnerr][_from];
        //   require(authorized != true , "You're not approved");
          bool authorzed = allowed[_from][msg.sender];
          require(authorzed != true , "You are not approved for this transfer");
          //balances[_id][_from] = (balances[_id][_from]).safeSub(_value);
          balances[_id][_from] = safeSub(balances[_id][_from] , _value);
          balances[_id][_to] = safeAdd(balances[_id][_to] , _value);
          //balances[_id][_to] = balances[_id][_to].add(_value);
          
          emit TransferSingle(msg.sender, _from, _to, _id, _value);
      }
      
       function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values) override external
       {
              require(_to != address(0),"Enter The Valid Address");
              bool authorzed = allowed[_from][msg.sender];
              require(authorzed != true , "You are not approved for this transfer");
              require(_ids.length == _values.length, "Enter same anounts & ids" );
              for(uint i=0 ; i<_ids.length; i++)
              {
                  uint id = _ids[i];
                  uint value = _values[i];
                  
                  balances[id][_from] = safeSub(balances[id][_from] , value);
                  balances[id][_to] = safeAdd(balances[id][_to] , value);
              }
              emit TransferBatch(msg.sender, _from, _to, _ids, _values);
           
       }
    
}