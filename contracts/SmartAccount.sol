// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@account-abstraction/contracts/core/BaseAccount.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract SmartAccount is BaseAccount, Initializable, UUPSUpgradeable {
    using ECDSA for bytes32;

    address public owner;
    IEntryPoint private _entryPoint;

    mapping(address => SessionKey) public sessionKeys;
    struct SessionKey {
        bool valid;
        uint256 expiresAt;
        uint256 spendLimit;
        uint256 spent;
    }

    event SessionKeyAdded(address indexed key, uint256 expiresAt);
    event Executed(address indexed to, uint256 value, bytes data);

    modifier onlyOwnerOrEntryPoint() {
        require(msg.sender == owner || msg.sender == address(_entryPoint), "Not authorized");
        _;
    }

    function initialize(address _owner, IEntryPoint entryPoint_) external initializer {
        owner = _owner;
        _entryPoint = entryPoint_;
    }

    function entryPoint() public view override returns (IEntryPoint) { return _entryPoint; }

    function execute(address to, uint256 value, bytes calldata data) external onlyOwnerOrEntryPoint {
        (bool ok,) = to.call{value: value}(data);
        require(ok, "Call failed");
        emit Executed(to, value, data);
    }

    function executeBatch(address[] calldata to, uint256[] calldata value, bytes[] calldata data) external onlyOwnerOrEntryPoint {
        for (uint256 i = 0; i < to.length; i++) {
            (bool ok,) = to[i].call{value: value[i]}(data[i]);
            require(ok, "Batch call failed");
        }
    }

    function addSessionKey(address key, uint256 duration, uint256 spendLimit) external {
        require(msg.sender == owner, "Only owner");
        sessionKeys[key] = SessionKey(true, block.timestamp + duration, spendLimit, 0);
        emit SessionKeyAdded(key, block.timestamp + duration);
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal view override returns (uint256) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        address signer = hash.recover(userOp.signature);
        if (signer == owner) return 0;
        SessionKey memory sk = sessionKeys[signer];
        if (sk.valid && block.timestamp < sk.expiresAt) return 0;
        return 1;
    }

    function _authorizeUpgrade(address) internal override { require(msg.sender == owner); }
    receive() external payable {}
}