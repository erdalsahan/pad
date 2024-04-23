<!--
    ProjectGallery component
    2024 © Atlaspad Launchpad
    Yigid BALABAN <fyb@fybx.dev>
-->
<script>
	import { onMount } from 'svelte';
	import ProjectCard from './ProjectCard.svelte';

	let galleryData = [];
	let loading = true;

	async function fetchData() {
		try {
			loading = true;
			const response = await fetch('/api/gallery.json');
			const data = await response.json();
            galleryData = data['data'];
		} catch (error) {
			console.error('Error fetching data:', error);
		} finally {
			loading = false;
		}
	}

	onMount(fetchData);
</script>

{#if loading}
	<div class="loading-animation">Loading...</div>
{:else}
	<div class="gallery">
		{#each galleryData as item}
            <ProjectCard name={item.name} flair={item.flair} details={item.details} chainSymbol={item.chain} />
		{/each}
	</div>
{/if}

<style>
	.loading-animation {
		display: flex;
		justify-content: center;
		align-items: center;
		height: 100px;
	}
	.gallery {
		display: flex;
        flex-wrap: wrap;
        justify-content: space-around;
        gap: 2rem 1rem;
	}
</style>
