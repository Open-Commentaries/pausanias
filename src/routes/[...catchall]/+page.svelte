<script lang="ts">
	import type { PageData } from './$types';

	export let data: PageData;

	$: config = data.config;
	$: body = data.body;
	$: title = data.title;

	function stripMarkdown(s: string): string {
		return s.replace(/_|\*/gi, '');
	}
</script>

<svelte:head>
	<title>{stripMarkdown(config.title)} • {title}</title>
</svelte:head>

<article class="prose">
	{@html body}
</article>
