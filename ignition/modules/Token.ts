import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const tokenModule = buildModule("Token", (module) => {
    const owner = vars.get("OWNER");
    const tokenName = vars.get("TOKEN_NAME");
    const ticker = vars.get("TOKEN_TICKER");

    const token = module.contract("Token", [owner, tokenName, ticker]);

    return { token };
});

export default tokenModule;
