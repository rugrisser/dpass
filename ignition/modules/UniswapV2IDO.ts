import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { vars } from "hardhat/config";

const uniswapV2IDOModule = buildModule("UniswapV2IDO", (module) => {
    const softCap = vars.get("SOFT_CAP");
    const hardCap = vars.get("HARD_CAP");
    const finishTimestamp = vars.get("FINISH_TIMESTAMP");
    const unfreezeTimestamp = vars.get("UNFREEZE_TIMESTAMP");
    const poolMintAmount = vars.get("POOL_MINT_AMOUNT");
    const shareMintAmount = vars.get("SHARE_MINT_AMOUNT");
    const idoToken = vars.get("IDO_TOKEN_ADDRESS");
    const targetToken = vars.get("TARGET_TOKEN_ADDRESS");
    const kyc = vars.get("KYC_ADDRESS");
    const owner = vars.get("OWNER");
    const uniswapPair = vars.get("UNISWAP_PAIR_ADDRESS");
    const rewardPercent = vars.get("REWARD_PERCENT");


    const ido = module.contract("UniswapV2IDO", [
        softCap,
        hardCap,
        finishTimestamp,
        unfreezeTimestamp,
        poolMintAmount,
        shareMintAmount, 
        idoToken,
        targetToken,
        kyc,
        owner,
        uniswapPair,
        rewardPercent
    ]);

    return { ido };
});

export default uniswapV2IDOModule;
