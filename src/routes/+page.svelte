<script>
	import ImageButton from '../lib/components/ImageButton.svelte';
	import TextButton from '../lib/components/TextButton.svelte';
	import StatisticWidget from '../lib/components/StatisticWidget.svelte';
</script>
<section id="hero">
	<div class="content">
		<h2>Meet the legend</h2>
		<h1>Atlaspad Launchpad</h1>
		<p>
			Atlaspad presents you world’s first fully trustless cross-chain launchpad powered by
			zero-knowledge.
		</p>
		<nav>
			<TextButton text="ICO Projects" />
			<ImageButton text="Discord" imgSource="discord.svg" />
			<ImageButton text="Stake $ATLAS" imgSource="staking.svg" />
		</nav>
		<StatisticWidget
			stats={[
				{ statTitle: 'ideas funded', statValue: '17 ICO' },
				{ statTitle: 'C-Supply Locked', statValue: '31.3%' },
				{ statTitle: 'Average ROI', statValue: '6.9x' }
			]}
		/>
	</div>
	<div class="atlas">
		<img
			alt="In Greek mythology, Atlas is a Titan condemned to hold up the heavens or sky for eternity after the Titanomachy."
			src="atlas.png"
		/>
	</div>
</section>
<section id="get-listed">
	<h1>Get listed on Atlaspad</h1>
	<p>
		Ready to change the world? Ready for lift-off? Contact us now to get your project listed on
		Atlaspad. Atlaspad provides an easy entry to a large ecosystem of multiple chains.
	</p>
	<p>
		Atlaspad Launchpad utilizes Mina Protocol’s zkApps to achieve a fast and efficient platform
		while innovating usual security approaches. Our launchpad has zero-knowledge at its core, so
		anyone can develop or participate in ultimate privacy.
	</p>
	<ImageButton imgSource="app.svg" text="I'm ready, let's do this!" />
</section>
<style lang="scss">
	section {
		min-height: 100vh;
		// don't hit the fixed header
		// 8rem for base and 2 extra rems for header's top margin, which is also 2 rem
		padding-top: calc(8rem + 2rem);
		box-sizing: border-box; // so the height is correctly calculated

		p {
			font:
				1.5rem 'Ubuntu',
				sans-serif;
			margin-bottom: 2rem;
			margin-right: 40%;
		}

		h1 {
			font:
				700 3rem 'Ubuntu',
				sans-serif;
			background: radial-gradient(111.8% 111.8% at 50% 0%, #88f2e7 0%, #35ada1 79.69%);
			background-clip: text;
			-webkit-background-clip: text;
			-webkit-text-fill-color: transparent;

			margin-bottom: 2rem;
		}
	}

	#hero {
		display: grid;
		grid-template-columns: 60% 40%;
		grid-template-rows: 1fr;
		grid-auto-columns: 1fr;
		gap: 0em 16px;
		grid-auto-flow: row;
		grid-template-areas: 'content atlas';

		.content {
			grid-area: content;

			display: flex;
			flex-direction: column;

			h2 {
				font:
					2rem 'GFS Neohellenic',
					serif;
			}

			nav {
				margin-bottom: 2rem;

				display: flex;
				align-items: center;
				column-gap: 1rem;
			}
		}

		.atlas {
			grid-area: atlas;
			img {
				float: right;
			}
		}
	}
</style>
