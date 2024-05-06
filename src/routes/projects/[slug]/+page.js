/* 	projects/[slug]/+page.js
 *	2024 © Atlaspad Launchpad
 *  Yigid BALABAN <fyb@fybx.dev
 */

import { error } from '@sveltejs/kit';
import { Contract, JsonRpcProvider } from 'ethers';
import APCampaign from '$lib/abi/APCampaign.json';

// TODO this section must change on demo day!!!
const rpcUrl = 'http://127.0.0.1:8545';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
	// step 1: get the metadata from offchain
	// we will mock the backend connection here, lol
	const response = await fetch('/api/gallery.json');
	const data = await response.json();

	const what = data.data.find((element) => element.id == params.slug);

	if (what == undefined) error(404, 'Not found');
	else {
		// step 2: the project exists, now gather onchain data
		const provider = new JsonRpcProvider(rpcUrl);
		const contract = new Contract(what.contractAddress, APCampaign.abi, provider);
		const data = await contract._data();

		what.parameters.contractAddress = what.contractAddress;
		what.parameters.startTime = new Date(Number(data.saleStartTime) * 1000).toString();
		what.parameters.endTime = new Date(Number(data.saleEndTime) * 1000);

		return what;
	}
}
