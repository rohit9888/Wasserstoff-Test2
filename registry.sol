pragma solidity ^0.8.0;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) public pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

library Byt {
    function createBytes(string memory functionName) public pure returns (bytes4) {
        return bytes4(keccak256(bytes(functionName)));
    }
}

contract Registry {
    bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1);
    mapping(bytes4 => address) public implementations;

    constructor() {
        _setAdmin(msg.sender);
    }

    function setImplementation(string memory functionName, address _implementation) external {
        bytes4 data = Byt.createBytes(functionName);
        implementations[data] = _implementation;
    }

    function _setAdmin(address _admin) private {
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    fallback() external payable {
        address implementation = implementations[msg.sig];
        require(implementation != address(0), 'Implementation not found');
        _delegate(implementation);
    }

    receive() external payable {}

    function _delegate(address _implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
