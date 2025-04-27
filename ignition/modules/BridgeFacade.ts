import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const BridgeFacadeModule = buildModule("BridgeFacade", (module) => {
    const owner = vars.get("OWNER");
    const kycContract = vars.get("KYC_CONTRACT");
    const messageBus = module.getParameter("messageBusAddress", "0x0");

    const brdigeFacade = module.contract("BridgeFacade", [kycContract, messageBus, owner]);
    return { brdigeFacade };
});

export default BridgeFacadeModule;
