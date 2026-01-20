// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      link: {
        type: 'generated-index',
        description: 'Get started with cdk-erigon, a high-performance execution client for Polygon zkEVM and CDK chains.',
      },
      collapsed: false,
      items: [
        'getting-started/introduction',
        'getting-started/system-requirements',
        'getting-started/quickstart',
        'getting-started/concepts',
      ],
    },
    {
      type: 'category',
      label: 'Installation',
      link: {
        type: 'generated-index',
        description: 'Install cdk-erigon using pre-built binaries, Docker, or build from source.',
      },
      items: [
        'installation/binaries',
        'installation/docker',
        'installation/build-from-source',
        'installation/kubernetes',
        'installation/hardware-recommendations',
      ],
    },
    {
      type: 'category',
      label: 'Running a Node',
      link: {
        type: 'generated-index',
        description: 'Run cdk-erigon as an RPC node or sequencer on various networks.',
      },
      items: [
        'running/rpc-node',
        'running/sequencer',
        {
          type: 'category',
          label: 'Networks',
          items: [
            'running/networks/mainnet',
            'running/networks/cardona',
            'running/networks/custom-cdk',
          ],
        },
        'running/operational-modes',
        'running/migration',
      ],
    },
    {
      type: 'category',
      label: 'Configuration',
      link: {
        type: 'generated-index',
        description: 'Configure cdk-erigon using CLI flags, environment variables, or YAML files.',
      },
      items: [
        'configuration/methods',
        'configuration/core-flags',
        'configuration/zkevm-namespace',
        'configuration/network-presets',
        'configuration/state-trie',
        'configuration/l1-interaction',
        'configuration/data-stream',
        'configuration/deprecated',
      ],
    },
    {
      type: 'category',
      label: 'JSON-RPC API',
      link: {
        type: 'generated-index',
        description: 'Complete reference for cdk-erigon JSON-RPC methods including the zkevm namespace.',
      },
      items: [
        'api/overview',
        'api/versioning',
        {
          type: 'category',
          label: 'zkevm Namespace',
          items: [
            'api/zkevm/batch-methods',
            'api/zkevm/block-methods',
            'api/zkevm/witness-methods',
            'api/zkevm/exit-root-methods',
            'api/zkevm/fork-methods',
            'api/zkevm/counter-methods',
            'api/zkevm/deprecated',
          ],
        },
        'api/standard-namespaces',
      ],
    },
    {
      type: 'category',
      label: 'Operations',
      link: {
        type: 'generated-index',
        description: 'Monitor, maintain, and optimize your cdk-erigon node.',
      },
      items: [
        'operations/monitoring',
        'operations/health-checks',
        'operations/database-management',
        'operations/backup-recovery',
        'operations/l1-recovery',
        'operations/performance-tuning',
        'operations/upgrading',
      ],
    },
    {
      type: 'category',
      label: 'Troubleshooting',
      link: {
        type: 'generated-index',
        description: 'Diagnose and resolve common issues with cdk-erigon.',
      },
      items: [
        'troubleshooting/sync-issues',
        'troubleshooting/memory-issues',
        'troubleshooting/l1-rpc-issues',
        'troubleshooting/log-interpretation',
        'troubleshooting/faq',
      ],
    },
    {
      type: 'category',
      label: 'Integration',
      link: {
        type: 'generated-index',
        description: 'Integrate cdk-erigon with the Polygon CDK stack.',
      },
      items: [
        'integration/architecture-overview',
        'integration/cdk-node',
        'integration/prover',
        'integration/bridge-service',
        'integration/kurtosis',
      ],
    },
    'glossary',
  ],
};

module.exports = sidebars;
