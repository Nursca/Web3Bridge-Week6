const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
	const WETHUSDCPairAddress = "0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc";
	const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
	const tokenHolder = "0x28C6c06298d514Db089934071355E5743bf21d60";

    const owner = await ethers.getSigner(tokenHolder);

    await helpers.impersonateAccount(tokenHolder);
    const impersonatedSigner = await ethers.getSigner(tokenHolder);

    const permitWallet = ethers.Wallet.createRandom().connect(ethers.provider);

    await owner.sendTransaction({
        to: impersonatedSigner.address,
        value: ethers.parseEther("1"),
    })

    await owner.sendTransaction({
        to: permitWallet.address,
        value: ethers.parseEther("1"),
    })

    const amountUSDC = ethers.parseUnits("100", 6);
    const amountTokenMin = ethers.parseUnits("1", 6);
    const amountETHMin = ethers.parseEther("0.01");
    const amountETHDesired = ethers.parseEther("0.1");
    const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

    const USDC = await ethers.getContractAt(
        "IERC20",
        USDCAddress,
        impersonatedSigner,
    );

    const LpToken = await ethers.getContractAt(
        "IUniswapV2Pair",
        WETHUSDCPairAddress,
        impersonatedSigner,
    );

    const ROUTER = await ethers.getContractAt(
        "IUniswapV2Router",
        UNIRouter,
        impersonatedSigner,
    );

    await USDC.connect(impersonatedSigner).transfer(permitWallet.address, amountUSDC);

    await USDC.connect(permitWallet).approve(UNIRouter, amountUSDC);

    const addLiquidity = await ROUTER.connect(permitWallet).addLiquidityETH(
        USDCAddress,
        amountUSDC,
        amountTokenMin,
        amountETHMin,
        permitWallet.address,
        deadline,
        { value: amountETHDesired},
    )

    await addLiquidity.wait();

    console.log("Liquidity added successfully");

    const lpBalanceBefore = await LpToken.balanceOf(permitWallet.address);
    console.log("LP balance before removing liquidity:", ethers.formatUnits(lpBalanceBefore, 18));

    const liquidityToRemove = lpBalanceBefore / BigInt(2);

    const amountTokenMinRemove = ethers.parseUnits("1", 6);
    const amountETHMinRemove = ethers.parseEther("0.001");
    const approveMaxium = false;

    const nonce = await LpToken.nonces(permitWallet.address);
    const pairName = await LpToken.name();

    const domain = {
        name: pairName,
        version: "1",
        chainId: 1,
        verifyingContract: WETHUSDCPairAddress,
    }

    const types = {
        Permit: [
            { name: "owner", type: "address" },
            { name: "spender", type: "address" },
            { name: "value", type: "uint256" },
            { name: "nonce", type: "uint256" },
            { name: "deadline", type: "uint256" },
        ],
    };

    const permitValue = {
        owner: permitWallet.address,
        spender: UNIRouter,
        value: liquidityToRemove,
        nonce: await nonce,
        deadline: deadline,
    }

    const signature = await permitWallet.signTypedData(domain, types, permitValue);
    const { v, r, s } = ethers.Signature.from(signature);

    const usdcBalanceBefore = await USDC.balanceOf(permitWallet.address);
    const ethBalanceBefore = await ethers.provider.getBalance(permitWallet.address);

    console.log("==========Before removing liquidity with permit==========")

    console.log("USDC Balance before removing liquidity:", ethers.formatUnits(usdcBalanceBefore, 6));
    console.log("ETH Balance before removing liquidity:", ethers.formatEther(ethBalanceBefore));
    console.log("LP balance before removing liquidity:", ethers.formatUnits(lpBalanceBefore, 18));

    const removeLiquidity = await ROUTER.connect(
        permitWallet
    ).removeLiquidityETHWithPermit(
        USDCAddress,
        liquidityToRemove,
        amountTokenMinRemove,
        amountETHMinRemove,
        permitWallet.address,
        deadline,
        approveMaxium,
        v, r, s,
    );

    await removeLiquidity.wait();

    const usdcBalanceAfter = await USDC.balanceOf(permitWallet.address);
    const ethBalanceAfter = await ethers.provider.getBalance(permitWallet.address);
    const lpBalanceAfter = await LpToken.balanceOf(permitWallet.address);

    console.log("==========After removing liquidity with permit==========");

    console.log("USDC Balance after removing liquidity:", ethers.formatUnits(usdcBalanceAfter, 6));
    console.log("ETH Balance after removing liquidity:", ethers.formatEther(ethBalanceAfter));
    console.log("LP balance after removing liquidity", ethers.formatUnits(lpBalanceAfter, 18));

    console.log("==========Difference==========");

    const newUsdcBalance = usdcBalanceAfter - usdcBalanceBefore;
    const newEthBalance = ethBalanceAfter - ethBalanceBefore;
    const newLpBalance = lpBalanceBefore - lpBalanceAfter;

    console.log("Difference in USDC balance", ethers.formatUnits(newUsdcBalance, 6));
    console.log("Difference in ETH balance", ethers.formatEther(newEthBalance));
    console.log("Difference in LP balance", ethers.formatUnits(newLpBalance, 18));

    console.log("Liquidity removed successfully with permit!");


}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});