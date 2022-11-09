import { DeployFunction } from "hardhat-deploy/dist/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { developmentChains, WAIT_CONFIRMATIONS } from "../helper-hardhat-config"

const deployCounter: DeployFunction = async (
    hre: HardhatRuntimeEnvironment
) => {

    //Getting infromtaion from hardhat-config.ts file
    const { getNamedAccounts, network, ethers, deployments } = hre

    //Getting deploy and log function from deployments 
    const { deploy, log } = deployments

    //Getting deployer config from named accounts config in hardhat-config.ts file
    const { deployer } = await getNamedAccounts()

    const args: any[] = []

    log("Start Deployment")

    const confirmations = developmentChains.includes(network.name)
        ? 1
        : WAIT_CONFIRMATIONS

        //Deploying Counter.sol smart contract using deploy function
    const counter = await deploy("Counter", {
        //Account from which we want to do the transaction
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: confirmations,
    })

    log(`Deployment Successful!`)
}


export default deployCounter
deployCounter.tags = ["all", "counter"]

