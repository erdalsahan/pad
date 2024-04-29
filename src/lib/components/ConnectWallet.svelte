<!-- 
	ConnectWallet component
    2024 © Atlaspad Launchpad
    Yigid BALABAN <fyb@fybx.dev>
-->

<script>
	export let imgSource;

	import { createWeb3Modal, defaultConfig } from '@web3modal/ethers';
	const projectId = 'dd033d756ef855ad1e5d50b7fadfa280';
	const mainnet = {
		chainId: 1,
		name: 'Ethereum',
		currency: 'ETH',
		explorerUrl: 'https://etherscan.io',
		rpcUrl: 'https://cloudflare-eth.com'
	};

	const metadata = {
		name: 'demolaunchpad',
		description: 'anti launchpad action',
		url: 'https://pad-balaban.vercel.app'
	};

	const ethersConfig = defaultConfig({
		metadata
	});

	let modal = createWeb3Modal({
		ethersConfig,
		chains: [mainnet],
		projectId,
		enableAnalytics: false
	});
</script>

<button on:click={() => modal.open()}>
	<img src={imgSource} alt="Button logo" /> Connect Wallet
</button>

<style lang="scss">
	button {
		display: inline-flex;
		padding: 0.5rem 1rem;
		justify-content: center;
		align-items: center;
		gap: 0.5rem;

		border: none;
		color: #fff;
		font-size: 1.5rem;
		border-radius: 1rem;
		background: radial-gradient(
			111.8% 111.8% at 50% 0%,
			rgba(136, 242, 231, 0.2) 0%,
			rgba(53, 173, 161, 0.2) 79.69%
		);
		box-shadow:
			1.333px -1.333px 1.333px 0px rgba(79, 174, 165, 0.42) inset,
			-1.333px 1.333px 1.333px 0px rgba(255, 255, 255, 0.42) inset;

		-webkit-backdrop-filter: blur(4px);
		backdrop-filter: blur(4px);

		img {
			height: 1.5rem;
			width: auto;
		}
	}
</style>
