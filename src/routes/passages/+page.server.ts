import { redirect } from "@sveltejs/kit";

import { base } from '$app/paths';

export const load = async ({ parent }) => {
    const parentData = await parent();
    const config = parentData.config;

    throw redirect(307, `${base}/passages/${config.passages[0].urn}`);
};