const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0x28C6c06298d514Db089934071355E5743bf21d60";
    
    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const amountOut = ethers.parseUnits("1000", 18); //DAI
    const amountInMax = ethers.parseUnits("1100", 6); //USDC
    const path = [USDCAddress, DAIAddress];
    const deadline = Math.floor(Date.now()/ 1000) + 60 * 10;

    const USDC = await ethers.getContractAt(
        "IERC20",
        USDCAddress,
        impersonatedSigner,
    );

    const DAI = await ethers.getContractAt(
        "IERC20",
        DAIAddress,
        impersonatedSigner,
    );

    const ROUTER = await ethers.getContractAt(
        "IUniswapV2Router",
        UNIRouter,
        impersonatedSigner,
    );

    await USDC.approve(UNIRouter, amountInMax);
    
    const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
    const daiBalBefore = await DAI.balanceOf(impersonatedSigner.address);

    console.log ("============Before============");

    console.log("USDC Balance before swap:", Number(usdcBalBefore));
    console.log("DAI Balance before swap:", Number(daiBalBefore));

    const tx = await ROUTER.swapTokensForExactTokens(
        amountOut,
        amountInMax,
        path,
        impersonatedSigner.address,
        deadline,
    );

    await tx.wait();

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    const daiBalAfter = await DAI.balanceOf(impersonatedSigner.address);

    console.log("============After============");

    console.log("USDC Balance after swap:", Number(usdcBalAfter));
    console.log("DAI Balance after swap:", Number(daiBalAfter));

    console.log("============Difference============");

    const newUsdcValue = Number(usdcBalBefore) - Number(usdcBalAfter);
    const newDaiValue = Number(daiBalAfter) - Number(daiBalBefore);

    console.log("USDC Difference:", newUsdcValue);
    console.log("DAI Difference:", newDaiValue);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});