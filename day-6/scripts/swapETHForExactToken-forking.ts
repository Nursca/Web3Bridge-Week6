const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0x28C6c06298d514Db089934071355E5743bf21d60";

    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const amountOut = ethers.parseUnits("1000", 6);
    const path = [WETHAddress, USDCAddress];
    const deadline = Math.floor(Date.now()/ 1000) + 60 * 10;
    
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

    const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
    const wethBalBefore = await ethers.provider.getBalance(impersonatedSigner.address);
    console.log(
        "=================Before========================================",
    );

    console.log("USDC Balance before swap:", Number(usdcBalBefore));
    console.log("WETH Balance before swap:", Number(wethBalBefore));

    const tx = await ROUTER.swapETHForExactTokens(
        amountOut,
        path,
        impersonatedSigner.address,
        deadline,
        {
            value: ethers.parseEther("0.5"),
        }
    );

    await tx.wait();

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    const wethBalAfter = await ethers.provider.getBalance(impersonatedSigner.address);

    console.log(
        "=================After========================================",
    );

    console.log("USDC Balance after swap:", Number(usdcBalAfter));
    console.log("WETH Balance after swap:", Number(wethBalAfter));

    console.log("=================Difference==============================");

    const newUsdcValue = Number(usdcBalAfter) - Number(usdcBalBefore);
    const newWethValue = (wethBalBefore) - (wethBalAfter);

    console.log("NEW USDC BALANCE:", ethers.formatUnits(newUsdcValue, 6));
    console.log("NEW WETH BALANCE:", ethers.formatEther(newWethValue));

    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});