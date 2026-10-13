import {
  useState,
  useEffect,
  useRef,
  type ReactNode,
  type KeyboardEvent as ReactKeyboardEvent,
  type PointerEvent as ReactPointerEvent,
} from 'react';
import Heading from '@theme/Heading';
import Link from '@docusaurus/Link';
import clsx from 'clsx';

import styles from './styles.module.css';

interface TimelinePoint {
  label: string;
  date: string;
  stars: number;
}

const INITIAL_POINTS: TimelinePoint[] = [
  {label: 'Mid Apr', date: 'Apr 15', stars: 280},
  {label: 'Late Apr', date: 'Apr 30', stars: 420},
  {label: 'Early May', date: 'May 10', stars: 750},
  {label: 'Mid May', date: 'May 20', stars: 1180},
  {label: 'Late May', date: 'May 31', stars: 1690},
  {label: 'Early Jun', date: 'Jun 10', stars: 2150},
  {label: 'Mid Jun', date: 'Jun 20', stars: 2620},
  {label: 'Late Jun', date: 'Jun 30', stars: 3120},
  {label: 'Early Jul', date: 'Jul 10', stars: 3680},
  {label: 'Mid Jul', date: 'Jul 20', stars: 4250},
  {label: 'Late Jul', date: 'Jul 31', stars: 4810},
  {label: 'Early Aug', date: 'Aug 10', stars: 5290},
  {label: 'Mid Aug', date: 'Aug 20', stars: 5740},
  {label: 'Late Aug', date: 'Aug 30', stars: 6150},
  {label: 'Early Sep', date: 'Sep 10', stars: 6510},
  {label: 'Mid Sep', date: 'Sep 20', stars: 6830},
  {label: 'Late Sep', date: 'Sep 30', stars: 7080},
  {label: 'Early Oct', date: 'Oct 08', stars: 7210},
  {label: 'Current', date: 'Oct 12', stars: 7289},
];

const CACHE_KEY = 'serpantinum:gh-stats';
const CACHE_TTL_MS = 60 * 60 * 1000;

interface CachedStats {
  time: number;
  stars?: number;
  forks?: number;
  merged?: number;
  unmerged?: number;
}

function readCache(): CachedStats | null {
  try {
    const raw = window.localStorage.getItem(CACHE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as CachedStats;
    return typeof parsed.time === 'number' ? parsed : null;
  } catch {
    return null;
  }
}

function writeCache(patch: Partial<CachedStats>): void {
  try {
    const next = {...(readCache() ?? {}), ...patch, time: Date.now()};
    window.localStorage.setItem(CACHE_KEY, JSON.stringify(next));
  } catch {}
}

function monthTicks(points: TimelinePoint[]): {label: string; position: number}[] {
  const seen = new Set<string>();
  const ticks: {label: string; position: number}[] = [];
  points.forEach((point, index) => {
    const month = point.date.split(' ')[0];
    if (seen.has(month)) return;
    seen.add(month);
    ticks.push({label: month, position: (index / (points.length - 1)) * 100});
  });
  return ticks;
}

function useCountUp(target: number, trigger: boolean, duration: number = 1400): number {
  const [count, setCount] = useState(0);

  useEffect(() => {
    if (!trigger) return;
    let startTimestamp: number | null = null;
    let animFrame: number;

    const step = (timestamp: number) => {
      if (!startTimestamp) startTimestamp = timestamp;
      const progress = Math.min((timestamp - startTimestamp) / duration, 1);
      const ease = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
      setCount(Math.round(target * ease));
      if (progress < 1) {
        animFrame = requestAnimationFrame(step);
      }
    };

    animFrame = requestAnimationFrame(step);
    return () => cancelAnimationFrame(animFrame);
  }, [target, trigger, duration]);

  return count;
}

export default function StarHistory(): ReactNode {
  const sectionRef = useRef<HTMLElement | null>(null);
  const plotRef = useRef<HTMLDivElement | null>(null);
  const [activeIndex, setActiveIndex] = useState<number | null>(null);
  const [points, setPoints] = useState<TimelinePoint[]>(INITIAL_POINTS);
  const [totalStars, setTotalStars] = useState<number>(7289);
  const [totalCommits] = useState<number>(596);
  const [mergedPRs, setMergedPRs] = useState<number>(65);
  const [unmergedPRs, setUnmergedPRs] = useState<number>(60);
  const [totalForks, setTotalForks] = useState<number>(312);
  const [hasScrolledIntoView, setHasScrolledIntoView] = useState<boolean>(false);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setHasScrolledIntoView(true);
        }
      },
      {threshold: 0.2},
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  useEffect(() => {
    const cached = readCache();
    const applyStars = (stars: number) => {
      setTotalStars(stars);
      setPoints((prev) =>
        prev.map((item, index) =>
          index === prev.length - 1 ? {...item, stars} : item,
        ),
      );
    };

    if (cached) {
      if (typeof cached.stars === 'number') applyStars(cached.stars);
      if (typeof cached.forks === 'number') setTotalForks(cached.forks);
      if (typeof cached.merged === 'number') setMergedPRs(cached.merged);
      if (typeof cached.unmerged === 'number') setUnmergedPRs(cached.unmerged);
      if (Date.now() - cached.time < CACHE_TTL_MS) return;
    }

    const getJson = (url: string) =>
      fetch(url).then((res) => (res.ok ? res.json() : Promise.reject()));

    getJson('https://api.github.com/repos/ilyamiro/serpantinum')
      .then((json) => {
        if (typeof json.stargazers_count === 'number') {
          applyStars(json.stargazers_count);
          writeCache({stars: json.stargazers_count});
        }
        if (typeof json.forks_count === 'number') {
          setTotalForks(json.forks_count);
          writeCache({forks: json.forks_count});
        }
      })
      .catch(() => {});

    getJson(
      'https://api.github.com/search/issues?q=repo:ilyamiro/serpantinum+type:pr+is:merged',
    )
      .then((json) => {
        if (typeof json.total_count === 'number') {
          setMergedPRs(json.total_count);
          writeCache({merged: json.total_count});
        }
      })
      .catch(() => {});

    getJson(
      'https://api.github.com/search/issues?q=repo:ilyamiro/serpantinum+type:pr+is:unmerged',
    )
      .then((json) => {
        if (typeof json.total_count === 'number') {
          setUnmergedPRs(json.total_count);
          writeCache({unmerged: json.total_count});
        }
      })
      .catch(() => {});
  }, []);

  const totalPRs = mergedPRs + unmergedPRs;

  const displayStars = useCountUp(totalStars, hasScrolledIntoView);
  const displayCommits = useCountUp(totalCommits, hasScrolledIntoView);
  const displayPRs = useCountUp(totalPRs, hasScrolledIntoView);
  const displayForks = useCountUp(totalForks, hasScrolledIntoView);

  const maxStars = Math.max(8000, Math.ceil(totalStars / 1000) * 1000);
  const coords = points.map((item, index) => ({
    x: (index / (points.length - 1)) * 100,
    y: Math.min(100, Math.max(0, (item.stars / maxStars) * 100)),
  }));
  const linePath = coords
    .map((c, i) => `${i === 0 ? 'M' : 'L'}${c.x.toFixed(2)},${(100 - c.y).toFixed(2)}`)
    .join(' ');
  const areaPath = `${linePath} L100,100 L0,100 Z`;
  const ticks = monthTicks(points);
  const activePoint = activeIndex === null ? null : points[activeIndex];

  const indexFromClientX = (clientX: number): number | null => {
    const el = plotRef.current;
    if (!el) return null;
    const rect = el.getBoundingClientRect();
    if (rect.width === 0) return null;
    const ratio = Math.min(1, Math.max(0, (clientX - rect.left) / rect.width));
    return Math.round(ratio * (points.length - 1));
  };

  const handlePointerMove = (e: ReactPointerEvent<HTMLDivElement>) => {
    setActiveIndex(indexFromClientX(e.clientX));
  };

  const handlePointerLeave = (e: ReactPointerEvent<HTMLDivElement>) => {
    if (e.pointerType === 'mouse') setActiveIndex(null);
  };

  const handleKeyDown = (e: ReactKeyboardEvent<HTMLDivElement>) => {
    const last = points.length - 1;
    if (e.key === 'ArrowRight') {
      e.preventDefault();
      setActiveIndex((i) => (i === null ? last : Math.min(last, i + 1)));
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      setActiveIndex((i) => (i === null ? last : Math.max(0, i - 1)));
    } else if (e.key === 'Home') {
      e.preventDefault();
      setActiveIndex(0);
    } else if (e.key === 'End') {
      e.preventDefault();
      setActiveIndex(last);
    } else if (e.key === 'Escape') {
      setActiveIndex(null);
    }
  };

  const yTicks = [
    `${Math.round(maxStars / 1000)}k`,
    `${Math.round((maxStars * 0.75) / 1000)}k`,
    `${Math.round((maxStars * 0.5) / 1000)}k`,
    `${Math.round((maxStars * 0.25) / 1000)}k`,
    '0',
  ];

  return (
    <section
      ref={sectionRef}
      className={styles.starSection}
      aria-label="GitHub Star History">
      <div className={styles.header}>
        <Heading as="h2" className={styles.title}>
          ilyamiro/serpantinum stars
        </Heading>
        <p className={styles.subtitle}>
          The growing community of{' '}
          <span className={styles.serpantinumGlow}>Serpantinum</span>
        </p>
      </div>

      <div className={styles.chartCard}>
        <div className={styles.metaRow}>
          <div className={styles.statGroup}>
            <div className={styles.statItem}>
              <span className={styles.statValue}>
                {displayStars.toLocaleString()}
              </span>
              <span className={styles.statLabel}>GitHub Stars</span>
            </div>
            <div className={styles.statItem}>
              <span className={styles.statValue}>
                {displayCommits.toLocaleString()}
              </span>
              <span className={styles.statLabel}>Commits</span>
            </div>
            <div className={styles.statItem}>
              <span className={styles.statValue}>
                {displayPRs.toLocaleString()}
              </span>
              <span className={styles.statLabel}>Pull Requests</span>
            </div>
            <div className={styles.statItem}>
              <span className={styles.statValue}>
                {displayForks.toLocaleString()}
              </span>
              <span className={styles.statLabel}>Forks</span>
            </div>
          </div>

          <Link
            className={styles.githubButton}
            href="https://github.com/ilyamiro/serpantinum/stargazers">
            <svg
              className={styles.starIcon}
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="currentColor">
              <path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z" />
            </svg>
            <span>Star on GitHub</span>
          </Link>
        </div>

        <div className={styles.chartContainer}>
          <div className={styles.yAxis} aria-hidden="true">
            {yTicks.map((tick, i) => (
              <span key={i} className={styles.yLabel}>
                {tick}
              </span>
            ))}
          </div>

          <div
            ref={plotRef}
            className={styles.plotArea}
            role="slider"
            tabIndex={0}
            aria-label="Star history"
            aria-valuemin={0}
            aria-valuemax={points.length - 1}
            aria-valuenow={activePoint ? activeIndex ?? 0 : 0}
            aria-valuetext={
              activePoint
                ? `${activePoint.stars.toLocaleString()} stars on ${activePoint.date}, 2026`
                : `${totalStars.toLocaleString()} stars`
            }
            onPointerDown={handlePointerMove}
            onPointerMove={handlePointerMove}
            onPointerLeave={handlePointerLeave}
            onKeyDown={handleKeyDown}
            onBlur={() => setActiveIndex(null)}>
            <div className={styles.gridLines} aria-hidden="true">
              {yTicks.map((_, i) => (
                <div key={i} className={styles.gridLine} />
              ))}
            </div>

            <svg
              className={styles.chartSvg}
              viewBox="0 0 100 100"
              preserveAspectRatio="none"
              aria-hidden="true">
              <defs>
                <linearGradient id="starAreaGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="var(--ifm-color-primary)" stopOpacity="0.35" />
                  <stop offset="100%" stopColor="var(--ifm-color-primary)" stopOpacity="0" />
                </linearGradient>
              </defs>
              <path
                d={areaPath}
                className={clsx(styles.area, hasScrolledIntoView && styles.areaVisible)}
                fill="url(#starAreaGradient)"
              />
              <path
                d={linePath}
                className={clsx(styles.line, hasScrolledIntoView && styles.lineVisible)}
                pathLength={1}
                fill="none"
              />
            </svg>

            {activePoint && activeIndex !== null && (
              <>
                <div
                  className={styles.cursorLine}
                  style={{left: `${coords[activeIndex].x}%`}}
                />
                <div
                  className={styles.cursorDot}
                  style={{
                    left: `${coords[activeIndex].x}%`,
                    bottom: `${coords[activeIndex].y}%`,
                  }}
                />
                <div
                  className={styles.tooltip}
                  style={{
                    left: `${Math.min(86, Math.max(14, coords[activeIndex].x))}%`,
                    bottom: `calc(${coords[activeIndex].y}% + 14px)`,
                  }}>
                  {activePoint.stars.toLocaleString()} stars
                  <span className={styles.tooltipDate}>{activePoint.date}, 2026</span>
                </div>
              </>
            )}
          </div>

          <div className={styles.xAxis} aria-hidden="true">
            {ticks.map((tick) => (
              <span
                key={tick.label}
                className={styles.xLabel}
                style={{left: `${tick.position}%`}}>
                {tick.label}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
