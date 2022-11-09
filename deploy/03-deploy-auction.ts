
import { DeployFunction } from "hardhat-deploy/dist/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { developmentChains, WAIT_CONFIRMATIONS } from "../helper-hardhat-config"
import verify from "../utils/verify"


const deployAuction: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {

    //Getting infromtaion from hardhat-config.ts file
    const { getNamedAccounts, network, ethers, deployments } = hre

    //Getting deploy and log function from deployments 
    const { deploy, log } = deployments

    //Getting deployer config from named accounts config in hardhat-config.ts file
    const { deployer } = await getNamedAccounts()

    const args: any[] = [1,1]

    log("Start Deployment of Auction contract")

    const confirmations = developmentChains.includes(network.name)
        ? 1
        : WAIT_CONFIRMATIONS

        //Deploying Counter.sol smart contract using deploy function
    const auction = await deploy("Auction", {
        //Account from which we want to do the transaction
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: confirmations,
    })

    log(`Deployment of Auction contractSuccessful!`)

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(auction.address, args)
    }
}


export default deployAuction
deployAuction.tags = ["all", "auction"]