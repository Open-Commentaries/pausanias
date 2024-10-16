import { loadConfig } from "kodon";

export const prerender = true;

export const load = () => {
    const config = loadConfig('config/commentary.toml');

    return {
        config,
        staticPages: config.static_pages,
        title: config.title
    };
};