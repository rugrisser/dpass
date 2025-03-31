import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const tokenModule = buildModule("Token", (module) => {
    const owner = vars.get("OWNER");
    const token = module.contract("Token", [owner]);

    return { token };
});

export default tokenModule;
