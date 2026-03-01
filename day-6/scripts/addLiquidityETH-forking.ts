const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0x28C6c06298d514Db089934071355E5743bf21d60";

    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const amountWETH = ethers.parseEther("10");
    const amountUSDC = ethers.parseUnits("10000", 6);
    const amountWETHMin = ethers.parseEther("0.1");
    const amountUSDCMin = ethers.parseUnits("9000", 6);
    const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

    const USDC = await ethers.getContractAt(
        "IERC20",
        USDCAddress,
        impersonatedSigner,
    );
    const ROUTER = await ethers.getContractAt(
        "IUniswapV2Router",
        UNIRouter,
        impersonatedSigner,
    );

    await USDC.approve(UNIRouter, amountUSDC);

    const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
    
    console.log("==========Before==========");

    console.log("USDC Balance before adding liquidity:", Number(usdcBalBefore));
    
    const tx = await ROUTER.addLiquidityETH(
        USDCAddress,
        amountUSDC,
        amountUSDCMin,
        amountWETHMin,
        impersonatedSigner.address,
        deadline,
        { value: amountWETH },
    );

    await tx.wait();

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    console.log("==========After==========");
    
    console.log("USDC Balance after adding liquidity:", Number(usdcBalAfter));

    console.log("Liquidity added successfully!");

}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});