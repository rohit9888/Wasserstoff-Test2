

contract Box {
 uint256 public number;

 function inc(uint256 _number) external {
 number += _number;
 }
}

