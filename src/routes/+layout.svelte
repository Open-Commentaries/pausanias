<script lang="ts">
	import { base } from '$app/paths';

	import { Header } from 'kodon';
	import '../app.css';

	import type { LayoutData } from './$types';

	export let data: LayoutData;
</script>

<main class="px-4">
	<Header title={data.title} staticPages={data.staticPages}>
		<a href="{base}/passages" class="link link-hover">A Pausanias Reader in Progress</a>
	</Header>
	<slot />
</main>
