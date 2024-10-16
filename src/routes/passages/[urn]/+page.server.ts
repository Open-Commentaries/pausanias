import { error } from '@sveltejs/kit';
import { loadPassage } from 'kodon';

export const prerender = true;

export const load = async ({ params: { urn = '' }, parent }) => {
    if (urn === '' || typeof urn === 'undefined') {
        return error(404);
    }

    const parentData = await parent();
    const config = parentData.config;

    return loadPassage(config)(urn);
};