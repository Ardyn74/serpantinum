import {
  useState,
  useEffect,
  useCallback,
  useRef,
  type ReactNode,
  type MouseEvent as ReactMouseEvent,
  type TouchEvent as ReactTouchEvent,
  type WheelEvent as ReactWheelEvent,
} from 'react';
import useBaseUrl from '@docusaurus/useBaseUrl';

import styles from './styles.module.css';

interface PreviewItem {
  id: number;
  src: string;
  alt: string;
}

const SLIDE_DURATION_MS = 5000;

export default function DesktopPreviews(): ReactNode {
  const previewItems: PreviewItem[] = [
    {
      id: 1,
      src: useBaseUrl('/img/previews/preview_1.png'),
      alt: 'Serpantinum Desktop Preview 1',
    },
    {
      id: 2,
      src: useBaseUrl('/img/previews/preview_2.png'),
      alt: 'Serpantinum Desktop Preview 2',
    },
    {
      id: 3,
      src: useBaseUrl('/img/previews/preview_3.png'),
      alt: 'Serpantinum Desktop Preview 3',
    },
    {
      id: 4,
      src: useBaseUrl('/img/previews/preview_4.png'),
      alt: 'Serpantinum Desktop Preview 4',
    },
  ];

  const sectionRef = useRef<HTMLElement | null>(null);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const [currentIndex, setCurrentIndex] = useState(0);
  const [prevIndex, setPrevIndex] = useState<number | null>(null);
  const [isRevealed, setIsRevealed] = useState(false);
  const [isDragging, setIsDragging] = useState(false);

  const isDraggingRef = useRef(false);
  const dragStartXRef = useRef(0);
  const dragDistanceRef = useRef(0);

  const touchStartXRef = useRef<number | null>(null);
  const touchStartYRef = useRef<number | null>(null);

  const transitionTo = useCallback(
    (nextIndex: number) => {
      setCurrentIndex((curr) => {
        if (nextIndex === curr) return curr;
        setPrevIndex(curr);
        return nextIndex;
      });
    },
    [],
  );

  const handleNext = useCallback(() => {
    setCurrentIndex((curr) => {
      const next = (curr + 1) % previewItems.length;
      setPrevIndex(curr);
      return next;
    });
  }, [previewItems.length]);

  const handlePrev = useCallback(() => {
    setCurrentIndex((curr) => {
      const prev = curr === 0 ? previewItems.length - 1 : curr - 1;
      setPrevIndex(curr);
      return prev;
    });
  }, [previewItems.length]);

  const resetTimer = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
    }
    timerRef.current = setInterval(() => {
      handleNext();
    }, SLIDE_DURATION_MS);
  }, [handleNext]);

  const handleManualNext = useCallback(() => {
    handleNext();
    resetTimer();
  }, [handleNext, resetTimer]);

  const handleManualPrev = useCallback(() => {
    handlePrev();
    resetTimer();
  }, [handlePrev, resetTimer]);

  const goToSlide = useCallback(
    (index: number) => {
      transitionTo(index);
      resetTimer();
    },
    [transitionTo, resetTimer],
  );

  useEffect(() => {
    resetTimer();
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    };
  }, [resetTimer]);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;

    const checkVisibility = () => {
      const rect = el.getBoundingClientRect();
      const windowHeight = window.innerHeight || document.documentElement.clientHeight;
      const inView = rect.top < windowHeight * 0.78 && rect.bottom > 80;
      setIsRevealed(inView);
    };

    window.addEventListener('scroll', checkVisibility, { passive: true });
    window.addEventListener('resize', checkVisibility, { passive: true });
    checkVisibility();

    return () => {
      window.removeEventListener('scroll', checkVisibility);
      window.removeEventListener('resize', checkVisibility);
    };
  }, []);

  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === 'ArrowLeft') {
        handleManualPrev();
      } else if (e.key === 'ArrowRight') {
        handleManualNext();
      }
    },
    [handleManualPrev, handleManualNext],
  );

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [handleKeyDown]);

  const handleMouseDown = (e: ReactMouseEvent<HTMLDivElement>) => {
    if (e.button !== 0) return;
    isDraggingRef.current = true;
    dragStartXRef.current = e.clientX;
    dragDistanceRef.current = 0;
    setIsDragging(true);
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDraggingRef.current) return;
      dragDistanceRef.current = e.clientX - dragStartXRef.current;
    };

    const handleMouseUp = () => {
      if (!isDraggingRef.current) return;
      isDraggingRef.current = false;
      setIsDragging(false);

      const distance = dragDistanceRef.current;
      dragDistanceRef.current = 0;

      if (distance < -50) {
        handleManualNext();
      } else if (distance > 50) {
        handleManualPrev();
      }
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [handleManualNext, handleManualPrev]);

  const handleTouchStart = (e: ReactTouchEvent<HTMLDivElement>) => {
    touchStartXRef.current = e.touches[0].clientX;
    touchStartYRef.current = e.touches[0].clientY;
  };

  const handleTouchEnd = (e: ReactTouchEvent<HTMLDivElement>) => {
    if (touchStartXRef.current === null) return;
    const endX = e.changedTouches[0].clientX;
    const endY = e.changedTouches[0].clientY;
    const dx = endX - touchStartXRef.current;
    const dy = endY - (touchStartYRef.current || endY);

    touchStartXRef.current = null;
    touchStartYRef.current = null;

    if (Math.abs(dx) > Math.abs(dy) && Math.abs(dx) > 40) {
      if (dx < 0) {
        handleManualNext();
      } else {
        handleManualPrev();
      }
    }
  };

  const handleWheel = (e: ReactWheelEvent<HTMLDivElement>) => {
    if (Math.abs(e.deltaX) > 40) {
      if (e.deltaX > 40) {
        handleManualNext();
      } else {
        handleManualPrev();
      }
    }
  };

  return (
    <section
      ref={sectionRef}
      className={styles.previewSection}
      aria-label="Desktop Showcases">
      <div className={styles.carouselContainer}>
        <button
          type="button"
          className={`${styles.navButton} ${
            isRevealed ? styles.navButtonPrevVisible : styles.navButtonPrevHidden
          }`}
          onClick={handleManualPrev}
          aria-label="Previous preview">
          <svg
            className={`${styles.arrowIcon} ${
              isRevealed ? styles.arrowIconPrevVisible : styles.arrowIconPrevHidden
            }`}
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.5"
            strokeLinecap="round"
            strokeLinejoin="round">
            <polyline points="15 18 9 12 15 6" />
          </svg>
        </button>

        <div
          className={`${styles.viewport} ${isDragging ? styles.viewportDragging : ''}`}
          onMouseDown={handleMouseDown}
          onTouchStart={handleTouchStart}
          onTouchEnd={handleTouchEnd}
          onWheel={handleWheel}>
          <div className={styles.slidesStage}>
            {previewItems.map((item, index) => {
              const isActive = index === currentIndex;
              const isExiting = index === prevIndex;
              let slideClass = styles.slide;
              if (isActive) {
                slideClass = `${styles.slide} ${styles.slideActive}`;
              } else if (isExiting) {
                slideClass = `${styles.slide} ${styles.slideExiting}`;
              }

              return (
                <div key={item.id} className={slideClass} aria-hidden={!isActive}>
                  <img
                    src={item.src}
                    alt={item.alt}
                    className={styles.previewImage}
                    draggable={false}
                    loading={index === 0 ? 'eager' : 'lazy'}
                  />
                </div>
              );
            })}
          </div>
        </div>

        <button
          type="button"
          className={`${styles.navButton} ${
            isRevealed ? styles.navButtonNextVisible : styles.navButtonNextHidden
          }`}
          onClick={handleManualNext}
          aria-label="Next preview">
          <svg
            className={`${styles.arrowIcon} ${
              isRevealed ? styles.arrowIconNextVisible : styles.arrowIconNextHidden
            }`}
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.5"
            strokeLinecap="round"
            strokeLinejoin="round">
            <polyline points="9 18 15 12 9 6" />
          </svg>
        </button>
      </div>

      <div className={styles.indicators}>
        {previewItems.map((item, index) => (
          <button
            key={item.id}
            type="button"
            className={`${styles.dot} ${
              index === currentIndex ? styles.dotActive : ''
            }`}
            onClick={() => goToSlide(index)}
            aria-label={`Go to preview ${index + 1}`}
          />
        ))}
      </div>
    </section>
  );
}
