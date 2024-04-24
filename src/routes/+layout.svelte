<script>
	import { onMount } from 'svelte';
	import Header from '../lib/partials/header.svelte';
	import calculatePadding from '../lib/utils/calculatePadding';
	import Footer from '../lib/partials/footer.svelte';

	let main;
	onMount(() => {
		calculatePadding(main, 'paddingInline');

		window.onresize = () => {
			calculatePadding(main, 'paddingInline');
		};
	});
</script>

<svelte:head>
	<!-- we might move those font import declarations to app.html -->
	<link rel="preconnect" href="https://fonts.googleapis.com" />
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
	<link
		href="https://fonts.googleapis.com/css2?family=GFS+Neohellenic&family=Ubuntu:wght@400;500;700&display=swap"
		rel="stylesheet"
	/>
</svelte:head>

<Header />

<main bind:this={main}>
	<slot></slot>
</main>

<Footer />

<style lang="scss">
	:global(*) {
		margin: 0;
		padding: 0;
		scroll-behavior: smooth;
	}

	:global(html) {
		height: -webkit-fill-available;
		height: -moz-available;
		height: fill-available;
		height: 100%;
	}

	:global(body) {
		min-height: -webkit-fill-available;
		min-height: -moz-available;
		min-height: fill-available;
		height: 100%;

		color: #fff;
		background-color: #0f0f0f;
	}

	:global(hr) {
		border: none;
		height: 1px;
		background: linear-gradient(
			90deg,
			rgba(255, 255, 255, 0.5) 0%,
			#fff 50%,
			rgba(255, 255, 255, 0.5) 100%
		);
	}

	:global(.font-monospace) {
		font-family: 'Ubuntu Mono', monospace !important;
	}

	:global(.color-muted) {
		color: #ccc;
	}
</style>
