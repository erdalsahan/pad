/* 	projects/[slug]/+page.js
 *	2024 © Atlaspad Launchpad
 *  Yigid BALABAN <fyb@fybx.dev
 */

import { error } from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export function load({ params }) {
	if (params.slug === 'demo') {
		// return the JSON required for the demo project
		return {
			id: 'demo',
			name: 'EtherLink',
			description:
				"# Introduction\nEtherLink is a decentralized platform that aims to revolutionize the way data is stored and accessed on the blockchain. Leveraging the power of decentralized storage solutions, EtherLink provides a secure, efficient, and censorship-resistant platform for storing and retrieving data. Whether it's documents, images, or any other type of digital content, EtherLink ensures data integrity and accessibility through its innovative technology.",
			parameters: {
				sale_contract_address: '0x123abc...',
				sale_supply: '100,000,000 ETHL',
				sale_rate: '1 ETHL per 0.0001 ETH',
				softcap: '5,000',
				hardcap: '20,000',
				liquidity: '7 days, 20% of total liquidity',
				vesting: '180 days, 10% every 30 days',
				total_sale: '6,000'
			},
			flairs: ['Presale'],
			socials: {
				discord: 'https://discord.com',
				github: 'https://github.com',
				twitter: 'https://twitter.com'
			}
		};
	}

	error(404, 'Not found');
}
