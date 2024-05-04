import { Contract, JsonRpcProvider } from 'ethers';
import apCampaignArtifacts from '../src/lib/abi/APCampaign.json' assert { type: 'json' };

const rpcUrl = 'http://127.0.0.1:8545';

const campaignAddress = '0xa16E02E87b7454126E5E10d957A927A7F5B5d2be';

async function main() {
	const provider = new JsonRpcProvider(rpcUrl);

	const apCampaign = new Contract(campaignAddress, apCampaignArtifacts.abi, provider);

	try {
		console.log('hey', campaignAddress);
		const result = await apCampaign._data();
		console.log('SUCCESS:', result);
	} catch (error) {
		console.error('ERROR:', error);
	}
}

main();
