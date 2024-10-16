import fs from 'node:fs';

import frontMatter from 'front-matter';
import { marked } from 'marked';
import { error } from '@sveltejs/kit';

export const prerender = true;

export const load = async ({ params, parent }) => {
    const { config } = await parent();
    const staticPage = config.static_pages.find((p: any) => p.path === `/${params.catchall}`);

    if (!staticPage) {
        throw error(404);
    }

    const s = fs.readFileSync(staticPage.file_path, 'utf-8');
    const { attributes, body: rawBody } = frontMatter(s);
    const body = marked(rawBody);

    return {
        body,
        config,
        title: (attributes as any).title || staticPage.title,
    };
};