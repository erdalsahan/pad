/* 	projects/[slug]/+page.js
 *	2024 © Atlaspad Launchpad
 *  Yigid BALABAN <fyb@fybx.dev
 */

import { error } from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
	// we will mock the backend connection here, lol
	const response = await fetch('/api/gallery.json');
	const data = await response.json();

	const what = data.data.find((element) => element.id == params.slug);

	if (what == undefined) error(404, 'Not found');
	else return what;
}
