import { useRef } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { MeshDistortMaterial, Float, Sparkles } from '@react-three/drei';

export default function HeroScene({ particleCount }) {
  const meshRef = useRef();
  const groupRef = useRef();
  const { viewport } = useThree();

  useFrame((state) => {
    const t = state.clock.getElapsedTime();
    if (meshRef.current) {
      meshRef.current.rotation.x = t * 0.12;
      meshRef.current.rotation.y = t * 0.18;
    }
    if (groupRef.current) {
      const targetX = (state.pointer.y * viewport.height) / 24;
      const targetY = (state.pointer.x * viewport.width) / 24;
      groupRef.current.rotation.x += (targetX - groupRef.current.rotation.x) * 0.04;
      groupRef.current.rotation.y += (targetY - groupRef.current.rotation.y) * 0.04;
    }
  });

  return (
    <group ref={groupRef}>
      <ambientLight intensity={0.6} />
      <pointLight position={[5, 5, 5]} intensity={60} color="#5eead4" />
      <pointLight position={[-5, -3, -5]} intensity={30} color="#6366f1" />

      <Float speed={1.4} rotationIntensity={0.5} floatIntensity={0.8}>
        <mesh ref={meshRef} position={[2.4, -0.3, -1.5]} scale={1.1}>
          <icosahedronGeometry args={[1.6, 4]} />
          <MeshDistortMaterial
            color="#5eead4"
            attach="material"
            distort={0.4}
            speed={1.6}
            roughness={0.15}
            metalness={0.4}
            transparent
            opacity={0.75}
            wireframe={false}
          />
        </mesh>
      </Float>

      <Sparkles count={particleCount} scale={[12, 9, 6]} size={2} speed={0.3} color="#5eead4" opacity={0.4} />
    </group>
  );
}
