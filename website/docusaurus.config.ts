import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Serpantinum',
  tagline: 'A wayland shell built for you',
  favicon: 'img/logo.svg',

  future: {
    v4: true,
  },

  url: 'https://serpantinum.dev',
  baseUrl: '/',

  organizationName: 'ilyamiro',
  projectName: 'serpantinum',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  headTags: [
    {
      tagName: 'link',
      attributes: {
        rel: 'preload',
        href: '/img/logo-dark.svg',
        as: 'image',
        type: 'image/svg+xml',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'preload',
        href: '/img/logo-light.svg',
        as: 'image',
        type: 'image/svg+xml',
      },
    },
    {
      tagName: 'link',
      attributes: {
        rel: 'preload',
        href: '/img/logo.svg',
        as: 'image',
        type: 'image/svg+xml',
      },
    },
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          path: '../docs',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/docusaurus-social-card.jpg',
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'Serpantinum',
      logo: {
        alt: 'Serpantinum Logo',
        src: 'img/logo-light.svg',
        srcDark: 'img/logo-dark.svg',
        width: 32,
        height: 32,
      },
      items: [
        {
          to: '/overview',
          label: 'Documentation',
          position: 'left',
        },
        {
          href: 'https://github.com/ilyamiro/serpantinum/blob/master/CHANGELOG.md',
          label: 'Changelog',
          position: 'left',
          className: 'navbar-changelog-link',
        },
        {
          href: 'https://github.com/ilyamiro/serpantinum',
          label: 'GitHub',
          position: 'right',
          className: 'navbar-github-link',
          'aria-label': 'GitHub repository',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Overview',
              to: '/overview',
            },
            {
              label: 'Installation',
              to: '/installation/arch',
            },
            {
              label: 'Variables',
              to: '/configure',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'Telegram',
              href: 'https://t.me/serpantinum_git',
            },
          ],
        },
        {
          title: 'Creator',
          items: [
            {
              label: 'X (Twitter)',
              href: 'https://x.com/ilyamirox',
            },
            {
              label: 'Reddit',
              href: 'https://reddit.com/user/ilyamiro1',
            },
            {
              label: 'YouTube',
              href: 'https://youtube.com/@ilyamiro21',
            },
            {
              label: 'TikTok',
              href: 'https://tiktok.com/@ilyamiro.dev',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/ilyamiro/serpantinum',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Serpantinum. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
