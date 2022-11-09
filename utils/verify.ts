
import { run } from "hardhat"

const verify = async (contractAddress: string, args: any[]) => {
    console.log("Verfying Contract")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (err: any) {
        if (err.message.toLowercase().includes("already verfied")) {
            console.log("Contract Already Verified!")
        } else {
            console.log(err)
        }
    }
}

export default verify