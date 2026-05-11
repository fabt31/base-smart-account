// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Create2.sol";
import "./SmartAccount.sol";
contract SmartAccountFactory {
    IEntryPoint public immutable entryPoint;
    constructor(IEntryPoint _entryPoint) { entryPoint = _entryPoint; }
    function createAccount(address owner, uint256 salt) external returns (SmartAccount account) {
        address addr = getAddress(owner, salt);
        if (addr.code.length > 0) return SmartAccount(payable(addr));
        bytes memory bytecode = abi.encodePacked(type(SmartAccount).creationCode, abi.encode(owner, entryPoint));
        account = SmartAccount(payable(Create2.deploy(0, bytes32(salt), bytecode)));
    }
    function getAddress(address owner, uint256 salt) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(type(SmartAccount).creationCode, abi.encode(owner, entryPoint));
        return Create2.computeAddress(bytes32(salt), keccak256(bytecode));
    }
}
interface IEntryPoint {}
