import adapter from '@sveltejs/adapter-static';
import fs from 'fs';
import { parse as parseToml } from 'smol-toml';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

const doc = fs.readFileSync('config/commentary.toml', 'utf-8');
const toml = parseToml(doc);
const prerenderPaths = toml.table_of_contents.map((passage) => `/passages/${passage.urn}`);

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({
			pages: 'build',
			assets: 'build',
			fallback: undefined,
			precompress: false,
			strict: false
		}),
		paths: {
			base: process.env.BASE_PATH
		},
		prerender: {
			entries: [...prerenderPaths, '/about'],
			handleHttpError: 'warn',
			handleMissingId: 'ignore'
		}
	}
};

export default config;
