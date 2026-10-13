import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  icon: ReactNode;
  description: ReactNode;
  to: string;
  actionText: string;
};

const iconProps = {
  width: 56,
  height: 56,
  viewBox: '0 0 24 24',
  fill: 'none',
  stroke: 'currentColor',
  strokeWidth: 1.6,
  strokeLinecap: 'round' as const,
  strokeLinejoin: 'round' as const,
  'aria-hidden': true,
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Built for you',
    icon: (
      <svg {...iconProps}>
        <circle cx="12" cy="12" r="3" />
        <path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z" />
      </svg>
    ),
    description:
      'Tune the look and behaviour of every part of the shell through simple configuration variables.',
    to: '/configure',
    actionText: 'Configure',
  },
  {
    title: 'Any compositor',
    icon: (
      <svg {...iconProps}>
        <rect x="3" y="4" width="8" height="7" rx="1.5" />
        <rect x="13" y="4" width="8" height="16" rx="1.5" />
        <rect x="3" y="13" width="8" height="7" rx="1.5" />
      </svg>
    ),
    description:
      'Runs on Hyprland, Sway and Niri. Serpantinum only provides the shell, your compositor keeps its own keybinds and monitors.',
    to: '/overview',
    actionText: 'Overview',
  },
  {
    title: 'Quick to install',
    icon: (
      <svg {...iconProps}>
        <path d="M12 3v12" />
        <path d="m7 10 5 5 5-5" />
        <path d="M4 19h16" />
      </svg>
    ),
    description:
      'Available for Arch Linux and its derivatives as well as NixOS, with step-by-step guides for both.',
    to: '/installation/arch',
    actionText: 'Install',
  },
];

function Feature({title, icon, description, to, actionText}: FeatureItem) {
  return (
    <div className={clsx('col col--4', styles.featureCol)}>
      <div className={styles.featureCard}>
        <div className={styles.iconWrapper}>
          {icon}
        </div>
        <div className={styles.featureBody}>
          <Heading as="h3" className={styles.featureTitle}>{title}</Heading>
          <p className={styles.featureDescription}>{description}</p>
        </div>
        <div className={styles.featureFooter}>
          <Link className={styles.actionField} to={to}>
            <span className={styles.actionLabel}>{actionText}</span>
            <div className={styles.submitTile}>
              <svg className={styles.chevronIcon} viewBox="0 0 16 16" fill="none">
                <path
                  d="M6 3.5L10.5 8L6 12.5"
                  stroke="currentColor"
                  strokeWidth="2.2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </div>
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features} aria-label="Features">
      <div className="container">
        <div className={clsx('row', styles.featuresRow)}>
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
