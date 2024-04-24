<!-- 
	header partial
    2024 © Atlaspad Launchpad
    Yigid BALABAN <fyb@fybx.dev>
-->
<script>
	import { onMount } from 'svelte';
	import ImageButton from '../components/ImageButton.svelte';
	import TextLink from '../components/TextLink.svelte';
	import calculatePadding from '../utils/calculatePadding';

	let header;
	onMount(() => {
		calculatePadding(header, 'marginInline');

		window.onresize = () => {
			calculatePadding(header, 'marginInline');
		};
	});
</script>

<header bind:this={header}>
	<img src="logomark.svg" alt="Atlaspad Launchpad logo" />

	<nav>
		<TextLink text={'Chatbot'} imgSource={'chatbot.svg'} />
		<TextLink text={'Documents'} imgSource={'docs.svg'} />
		<TextLink text={'Staking'} imgSource={'staking.svg'} />
	</nav>

	<ImageButton text={'Launch App'} imgSource={'app.svg'} />
</header>

<style lang="scss">
	header {
		z-index: 100;
		position: fixed;
		margin-block: 2rem;

		box-sizing: border-box;
		display: flex;
		padding: 16px 48px;
		justify-content: space-between;
		align-items: center;

		border-radius: 16px;
		background: rgba(217, 217, 217, 0.1);
		box-shadow:
			1.333px -1.333px 1.333px 0px rgba(182, 182, 182, 0.4) inset,
			-1.333px 1.333px 1.333px 0px rgba(255, 255, 255, 0.4) inset;
		-webkit-backdrop-filter: blur(7px);
		backdrop-filter: blur(7px);

		nav {
			display: inline-flex;
		}
	}
</style>
