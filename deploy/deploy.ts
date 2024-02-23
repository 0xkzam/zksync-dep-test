import { deployContract } from "./utils";

export default async function () {

  const contractCF = "CrowdFundingBase";
  const contractEC = "EchoContractA";
  const contractToken = "HunterXERC20Token";
  // await deployContract(contractCF);
  // await deployContract(contractEC);
  // await deployContract(contractToken);

  const contractNFT = "HunterXNFT";
  const name = "HunterX NFT";
  const symbol = "HunterX";
  const baseTokenURI = "https://mybaseuri.com/token/";    
  // await deployContract(contractNFT, [name, symbol, baseTokenURI]);


  const contractPaymasterGeneral = "GeneralPaymaster";    
  // await deployContract(contractPaymasterGeneral);
  
  const contractPaymasterApproval = "ApprovalPaymaster";
  const tokenHTX = "0xb0d486951DfA93253F75D7F9EA7cf3a8bee6BCC5"
  await deployContract(contractPaymasterApproval, [tokenHTX]);
  

}