import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const KYCModule = buildModule("KYC", (module) => {
    const owner = vars.get("OWNER");
    const chainId = module.getParameter("chainId", 1);

    const kyc = module.contract("KYC", [owner, chainId]);
    return { kyc };
});

export default KYCModule;
