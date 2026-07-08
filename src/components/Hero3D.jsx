import { useEffect, useState } from 'react';
import { Canvas } from '@react-three/fiber';
import HeroScene from './HeroScene.jsx';

export default function Hero3D() {
  const [enabled, setEnabled] = useState(true);
  const [particleCount, setParticleCount] = useState(80);

  useEffect(() => {
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const isSmallScreen = window.innerWidth < 640;
    setEnabled(!prefersReducedMotion);
    setParticleCount(isSmallScreen ? 30 : 80);
  }, []);

  if (!enabled) {
    return (
      <div className="absolute inset-0 -z-10 bg-gradient-to-br from-ink via-[#0f2a28] to-ink" aria-hidden="true" />
    );
  }

  return (
    <div className="absolute inset-0 -z-10">
      <Canvas camera={{ position: [0, 0, 6], fov: 45 }} dpr={[1, 1.5]} gl={{ antialias: true, alpha: true }}>
        <HeroScene particleCount={particleCount} />
      </Canvas>
    </div>
  );
}
