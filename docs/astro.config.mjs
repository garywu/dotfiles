import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://garywu.github.io',
  base: '/dotfiles',
  integrations: [
    starlight({
      title: 'Dotfiles Academy',
      description: 'Master modern development environments and command-line tools',
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
          items: [
            { label: 'Getting Started', link: '/01-introduction/getting-started/' },
            { label: 'Architecture Overview', link: '/01-introduction/architecture-overview/' },
          ],
        },
        {
          label: 'CLI Tools',
          items: [
            { label: 'Modern Replacements', link: '/03-cli-tools/modern-replacements/' },
            { label: 'Password Management', link: '/03-cli-tools/password-management/' },
          ],
        },
        {
          label: 'Terminal Workflow',
          items: [
            { label: 'Tmux', link: '/04-terminal-workflow/tmux/' },
          ],
        },
        {
          label: 'AI Development',
          items: [
            { label: 'Chatblade', link: '/05-ai-development/chatblade/' },
            { label: 'Ollama', link: '/05-ai-development/ollama/' },
          ],
        },
        {
          label: 'CLI Tools Academy',
          items: [
            { label: 'Overview', link: '/05-cli-tools-academy/' },
            { label: 'Modern Replacements', link: '/05-cli-tools-academy/modern-replacements/' },
          ],
        },
        {
          label: 'AI Tools',
          items: [
            { label: 'Overview', link: '/06-ai-tools/' },
            { label: 'Ollama', link: '/06-ai-tools/ollama/' },
            { label: 'OpenHands', link: '/06-ai-tools/openhands/' },
          ],
        },
        {
          label: 'Troubleshooting',
          items: [
            { label: 'Git Email Privacy', link: '/98-troubleshooting/git-email-privacy/' },
            { label: 'Homebrew Fish Config', link: '/98-troubleshooting/homebrew-fish-config/' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'Command Cheatsheets', link: '/99-reference/command-cheatsheets/' },
          ],
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
