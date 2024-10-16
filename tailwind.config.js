import { join } from 'node:path';

/** @type {import('tailwindcss').Config} */
export default {
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		join(require.resolve('kodon'), '../**/*.{html,js,svelte,ts}')
	],
	daisyui: {
		themes: ['corporate']
	},
	theme: {
		extend: {
			fontFamily: {
				// Helvetica messes up kerning when diacritics are involved
				sans: ['Inter', 'Arial']
			}
		}
	},
	plugins: [require('@tailwindcss/typography'), require('daisyui')]
};
