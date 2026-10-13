import type {ReactNode, CSSProperties} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import DesktopPreviews from '@site/src/components/DesktopPreviews';
import SupportedPlatforms from '@site/src/components/SupportedPlatforms';
import StarHistory from '@site/src/components/StarHistory';
import AnimatedLogo from '@site/src/components/AnimatedLogo';
import FluidBackground from '@site/src/components/FluidBackground';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  const titleText = siteConfig.title;

  return (
    <header className={clsx('hero', styles.heroBanner)}>
      <div className="container">
        <AnimatedLogo />
        <Heading as="h1" className={clsx('hero__title', styles.waveTitle)}>
          {Array.from(titleText).map((char, index) => (
            <span
              key={index}
              className={styles.waveChar}
              style={{'--char-index': index} as CSSProperties}>
              {char === ' ' ? '\u00A0' : char}
            </span>
          ))}
        </Heading>
        <p className={clsx('hero__subtitle', styles.heroSubtitle)}>
          {siteConfig.tagline}
        </p>
        <div className={styles.buttons}>
          <Link className={styles.actionButton} to="/getting-started">
            Get started
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Description will go into a meta tag in <head />">
      <div className={styles.pageWrapper}>
        <FluidBackground />
        <HomepageHeader />
        <main className={styles.mainContent}>
          <DesktopPreviews />
          <SupportedPlatforms />
          <StarHistory />
        </main>
      </div>
    </Layout>
  );
}
