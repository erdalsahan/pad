/* 	calculatePadding utility
 *	2024 © Atlaspad Launchpad
 *  Yigid BALABAN <fyb@fybx.dev
 */
export default () => {
	// the magic unitless value 0.14 is the m for y = mx + n
	// that points (320, 16) and (1920, 240) pass through.
	let value = 0.14 * (window.innerWidth - 320) + 16;
	document.body.style.paddingInline = `${value}px`;
	return window.innerWidth - value * 2;
};
