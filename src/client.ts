import { ethers } from "ethers";
const FACTORY_ABI = ["function createAccount(address owner, uint256 salt) returns (address account)", "function getAddress(address owner, uint256 salt) view returns (address)"];
export async function createSmartAccount(config: { owner: string; factoryAddress: string; rpc: string; salt?: number }) {
  const provider = new ethers.JsonRpcProvider(config.rpc);
  const factory = new ethers.Contract(config.factoryAddress, FACTORY_ABI, provider);
  const salt = config.salt ?? 0;
  const predictedAddress = await factory.getAddress(config.owner, salt);
  const code = await provider.getCode(predictedAddress);
  const deployed = code !== "0x";
  return { address: predictedAddress, deployed, owner: config.owner };
}
