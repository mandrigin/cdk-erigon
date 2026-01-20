// @ts-check
// Docusaurus configuration for cdk-erigon documentation

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'cdk-erigon',
  tagline: 'Erigon fork optimized for Polygon zkEVM and CDK chains',
  favicon: 'img/favicon.ico',

  url: 'https://docs.polygon.technology',
  baseUrl: '/cdk-erigon/',

  organizationName: '0xPolygon',
  projectName: 'cdk-erigon',

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/0xPolygon/cdk-erigon/tree/zkevm/docs/',
          showLastUpdateTime: true,
          showLastUpdateAuthor: true,
          versions: {
            current: {
              label: 'Next',
              path: 'next',
            },
          },
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      image: 'img/cdk-erigon-social-card.png',
      navbar: {
        title: 'cdk-erigon',
        logo: {
          alt: 'cdk-erigon Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'docsSidebar',
            position: 'left',
            label: 'Docs',
          },
          {
            type: 'docsVersionDropdown',
            position: 'right',
            dropdownActiveClassDisabled: true,
          },
          {
            href: 'https://github.com/0xPolygon/cdk-erigon',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Documentation',
            items: [
              {
                label: 'Getting Started',
                to: '/docs/getting-started',
              },
              {
                label: 'Configuration',
                to: '/docs/configuration',
              },
              {
                label: 'API Reference',
                to: '/docs/api',
              },
            ],
          },
          {
            title: 'Polygon Ecosystem',
            items: [
              {
                label: 'Polygon CDK',
                href: 'https://docs.polygon.technology/cdk/',
              },
              {
                label: 'Polygon zkEVM',
                href: 'https://docs.polygon.technology/zkEVM/',
              },
              {
                label: 'Polygon Portal',
                href: 'https://portal.polygon.technology/',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Discord',
                href: 'https://discord.gg/polygon',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/0xPolygon/cdk-erigon',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/0xPolygon',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Polygon Technology. Built with Docusaurus.`,
      },
      prism: {
        theme: require('prism-react-renderer').themes.github,
        darkTheme: require('prism-react-renderer').themes.dracula,
        additionalLanguages: ['bash', 'json', 'yaml', 'toml', 'go'],
      },
      algolia: {
        appId: 'YOUR_APP_ID',
        apiKey: 'YOUR_SEARCH_API_KEY',
        indexName: 'cdk-erigon',
        contextualSearch: true,
      },
    }),
};

module.exports = config;
