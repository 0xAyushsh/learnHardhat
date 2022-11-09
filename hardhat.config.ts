import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "hardhat-deploy"
import "dotenv/config"

const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL || ""
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL || ""
const PRIVATE_KEY = process.env.PRIVATE_KEY || ""
const ETHERSCAN_API_KEY = process.env.ETHERCAN_API_KEY || ""

const config: HardhatUserConfig = {
    solidity: {
        compilers: [{ version: "0.8.17" }],
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        localhost: {
            chainId: 31337,
        },
        goerli: {
            url: GOERLI_RPC_URL,
            chainId: 5,
            accounts: [PRIVATE_KEY],
        },
        rinkeby: {
            url: RINKEBY_RPC_URL,
            chainId: 4,
            accounts: [PRIVATE_KEY],
        },
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
    gasReporter: {
        enabled: true,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true,
    },
    etherscan :{
        apiKey:{
            goerli : ETHERSCAN_API_KEY,
        }
    }
    // etherscan: {
    //     apiKey: {
    //         goerli: ETHERSCAN_API_KEY
    //         // rinkeby: ETHERSCAN_API_KEY,
    //         // polygon: POLYGONSCAN_API_KEY,
    //         // mumbai: POLYGONSCAN_API_KEY
    //         // avalnache: SNOWTRACE_API_KEY,
    //         // fuji: SNOWTRACE_API_KEY
    //     },
}

export default config