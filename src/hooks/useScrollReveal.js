import { useEffect } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export default function useScrollReveal(deps = []) {
  useEffect(() => {
    const ctx = gsap.context(() => {
      const elements = gsap.utils.toArray('.reveal');
      elements.forEach((el, i) => {
        gsap.to(el, {
          opacity: 1,
          y: 0,
          duration: 0.8,
          ease: 'power3.out',
          delay: (i % 4) * 0.08,
          scrollTrigger: {
            trigger: el,
            start: 'top 88%',
            toggleActions: 'play none none reverse',
          },
        });
      });
    });

    // Images (project screenshots) load asynchronously and shift layout after
    // ScrollTrigger's initial measurement, which can leave later sections
    // pinned at start-state (invisible) — refresh once everything has settled.
    const images = Array.from(document.images);
    const pending = images.filter((img) => !img.complete);
    let refreshTimer;
    if (pending.length) {
      let remaining = pending.length;
      const onLoad = () => {
        remaining -= 1;
        if (remaining === 0) ScrollTrigger.refresh();
      };
      pending.forEach((img) => img.addEventListener('load', onLoad, { once: true }));
    } else {
      refreshTimer = setTimeout(() => ScrollTrigger.refresh(), 50);
    }

    return () => {
      ctx.revert();
      clearTimeout(refreshTimer);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}
