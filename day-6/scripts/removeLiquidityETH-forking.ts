const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
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

    const factoryAddress = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    const factory = await ethers.getContractAt(
        "IUniswapV2Factory",
        factoryAddress,
        impersonatedSigner,
    );

    const pairAddress = await factory.getPair(USDCAddress, WETHAddress);
    const pair = await ethers.getContractAt(
        "IERC20",
        pairAddress,
        impersonatedSigner,
    );

    console.log("==========Before Adding Liquidity==========");
    
    const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
    const wethBalBefore = await ethers.provider.getBalance(impersonatedSigner.address);

    await USDC.approve(UNIRouter, amountUSDC);
    
    console.log("USDC Balance:", ethers.formatUnits(usdcBalBefore, 6));
    console.log("WETH Balance:", ethers.formatEther(wethBalBefore));

    const addTx = await ROUTER.addLiquidityETH(
        USDCAddress,
        amountUSDC,
        amountUSDCMin,
        amountWETHMin,
        impersonatedSigner.address,
        deadline,
        { value: amountWETH },
    );

    await addTx.wait();

    const liquidityBalance = await pair.balanceOf(impersonatedSigner.address);
    console.log("Liquidity Balance After Adding:", ethers.formatUnits(liquidityBalance, 18));

    await pair.approve(UNIRouter, liquidityBalance);

    const removeTx = await ROUTER.removeLiquidityETH(
        USDCAddress,
        liquidityBalance,
        amountUSDCMin,
        amountWETHMin,
        impersonatedSigner.address,
        deadline,
    );

    await removeTx.wait();

    console.log("Liquidity removed successfully!");

    console.log("==========After Removing Liquidity==========");

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    const wethBalAfter = await ethers.provider.getBalance(impersonatedSigner.address);

    console.log("WETH Balance:", ethers.formatEther(wethBalAfter));
    console.log("USDC Balance:", ethers.formatUnits(usdcBalAfter, 6));

    const liquidityBalanceAfter = await pair.balanceOf(impersonatedSigner.address);
    console.log("Liquidity Balance After Removing:", ethers.formatUnits(liquidityBalanceAfter, 18));

    const usdcUsed = usdcBalBefore - usdcBalAfter;
    const wethUsed = wethBalBefore - wethBalAfter;

    console.log("USDC Used in Liquidity:", ethers.formatUnits(usdcUsed, 6));
    console.log("WETH Used in Liquidity:", ethers.formatEther(wethUsed));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});