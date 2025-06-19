import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://garywu.github.io',
  base: '/dotfiles',
  output: 'static',
  integrations: [
    starlight({
      title: 'Dotfiles',
      description: 'Development environment configuration and command-line tools',
      defaultLocale: 'root',
      locales: {
        root: {
          label: 'English',
          lang: 'en',
        },
      },
      logo: {
        src: './src/assets/hero.svg',
        replacesTitle: false,
      },
      social: [
        {
          label: 'GitHub',
          icon: 'github',
          href: 'https://github.com/garywu/dotfiles',
        },
      ],
      sidebar: [
        {
          label: 'Getting Started',
          autogenerate: { directory: '01-introduction' },
        },
        {
          label: 'Platform Setup',
          autogenerate: { directory: '02-platform-setup' },
        },
        {
          label: 'CLI Tools',
          autogenerate: { directory: '03-cli-tools' },
        },
        {
          label: 'Terminal Workflow',
          autogenerate: { directory: '04-terminal-workflow' },
        },
        {
          label: 'AI Development',
          autogenerate: { directory: '05-ai-development' },
        },
        {
          label: 'AI Tools',
          autogenerate: { directory: '06-ai-tools' },
        },
        {
          label: 'Security',
          autogenerate: { directory: '07-security' },
        },
        {
          label: 'Development',
          autogenerate: { directory: '08-development' },
        },
        {
          label: 'Troubleshooting',
          autogenerate: { directory: '98-troubleshooting' },
        },
        {
          label: 'Reference',
          autogenerate: { directory: '99-reference' },
        },
      ],
      customCss: [
        './src/styles/custom.css',
      ],
      head: [
        {
          tag: 'script',
          content: `
            // Force light theme as default
            (function() {
              if (!localStorage.getItem('starlight-theme')) {
                localStorage.setItem('starlight-theme', 'light');
                document.documentElement.dataset.theme = 'light';
              }
            })();
          `
        }
      ],
    }),
  ],
});
