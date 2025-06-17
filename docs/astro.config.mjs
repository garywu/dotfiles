import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://garywu.github.io',
  base: '/dotfiles',
  integrations: [
    starlight({
      title: 'Dotfiles Academy',
      description: 'Master modern development environments and command-line tools',
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
          label: 'Installation & Setup',
          autogenerate: { directory: '02-installation' },
        },
        {
          label: 'Dotfiles Fundamentals',
          autogenerate: { directory: '03-dotfiles-fundamentals' },
        },
        {
          label: 'Shell Mastery',
          autogenerate: { directory: '04-shell-mastery' },
        },
        {
          label: 'CLI Tools Academy',
          items: [
            {
              label: 'Overview',
              link: '/05-cli-tools-academy/',
            },
            {
              label: 'Modern Replacements',
              link: '/05-cli-tools-academy/modern-replacements/',
            },
            {
              label: 'File Navigation',
              autogenerate: { directory: '05-cli-tools-academy/file-navigation' },
            },
            {
              label: 'Text Processing',
              autogenerate: { directory: '05-cli-tools-academy/text-processing' },
            },
            {
              label: 'System Monitoring',
              autogenerate: { directory: '05-cli-tools-academy/system-monitoring' },
            },
            {
              label: 'Git Workflow',
              autogenerate: { directory: '05-cli-tools-academy/git-workflow' },
            },
            {
              label: 'Data Tools',
              autogenerate: { directory: '05-cli-tools-academy/data-tools' },
            },
            {
              label: 'Productivity Tools',
              autogenerate: { directory: '05-cli-tools-academy/productivity' },
            },
          ],
        },
        {
          label: 'AI Tools',
          autogenerate: { directory: '06-ai-tools' },
        },
        {
          label: 'Development Workflow',
          autogenerate: { directory: '07-development-workflow' },
        },
        {
          label: 'Automation Scripts',
          autogenerate: { directory: '08-automation-scripts' },
        },
        {
          label: 'Advanced Topics',
          autogenerate: { directory: '09-advanced-topics' },
        },
        {
          label: 'Reference',
          autogenerate: { directory: '99-reference' },
        },
      ],
      customCss: [
        './src/styles/custom.css',
      ],
    }),
  ],
});