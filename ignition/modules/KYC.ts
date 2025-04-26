import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const KYCModule = buildModule("KYC", (module) => {
    const owner = vars.get("OWNER");

    const kyc = module.contract("KYC", [owner]);
    return { kyc };
});

export default KYCModule;
