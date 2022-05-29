// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ContractDeploy {
    event Deployed(string s, address addr);

    fallback() external payable {}

    receive() external payable {}

    function createByteCodeTwo(uint256 _x, uint256 _y)
        public
        payable
        returns (bytes memory)
    {
        bytes memory bytCode = type(Two).creationCode;

        return abi.encodePacked(bytCode, abi.encode(_x, _y));
    }

    function deployTwo(uint256 _x, uint256 _y)
        public
        payable
        returns (address addr)
    {
        bytes memory _byteCode;
        _byteCode = createByteCodeTwo(_x, _y);

        assembly {
            addr := create(callvalue(), add(_byteCode, 0x20), mload(_byteCode))
        }
        require(addr != address(0), "Zero address returned on 2");
        emit Deployed("address here:", addr);
    }

    function createByteCodeOne() public payable returns (bytes memory) {
        bytes memory byteCode = type(One).creationCode;
        return byteCode;
    }

    function deployOne() public payable returns (address adr) {
        bytes memory _byteCode;
        _byteCode = createByteCodeOne();

        assembly {
            adr := create(callvalue(), add(_byteCode, 0x20), mload(_byteCode))
        }
        require(adr != address(0), "Zero address returned on 1");
        emit Deployed("address here:", adr);
    }

    function changeOwner(address _contractAddr, address _owner) public payable {
        bytes memory _data = abi.encodeWithSignature(
            "setOwner(address)",
            _owner
        );

        (bool success, ) = _contractAddr.call{value: msg.value}(_data);
        require(success, "failed");
    }
}

contract One {
    address public owner = msg.sender;

    function setOwner(address _owner) public {
        require(msg.sender == owner, "Not owner");
        owner = _owner;
    }
}

contract Two {
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;

    constructor(uint256 _x, uint256 _y) payable {
        x = _x;
        y = _y;
    }
}
