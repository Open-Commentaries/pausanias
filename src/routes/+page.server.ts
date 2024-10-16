import fs from 'node:fs';
import { redirect } from "@sveltejs/kit";
import { marked } from "marked";

import { base } from '$app/paths';

export const load = async ({ parent }) => {
    const parentData = await parent();
    const config = parentData.config;

    if (config.home_page) {
        return { body: marked(fs.readFileSync(config.home_page, 'utf-8')) };
    }

    throw redirect(307, `${base}/passages/${config.passages[0].urn}`);
};