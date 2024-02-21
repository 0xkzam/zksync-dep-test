import { deployContract } from "./utils";

export default async function () {
  //const contractArtifactName = "CrowdFundingBase";
  const contractArtifactName = "EchoContractA";
  await deployContract(contractArtifactName);
}
