import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const BridgeFacadeModule = buildModule("BridgeFacade", (module) => {
    const owner = vars.get("OWNER");

    const brdigeFacade = module.contract("BridgeFacade", [owner]);
    return { brdigeFacade };
});

export default BridgeFacadeModule;
