'use client';

import { Canvas } from '@react-three/fiber';
import { useFrame } from '@react-three/fiber';
import { useRef } from 'react';
import type { Mesh } from 'three';

function Box() {
  const ref = useRef<Mesh>(null!);
  useFrame(() => {
    ref.current.rotation.x += 0.01;
    ref.current.rotation.y += 0.01;
  });
  return (
    <mesh ref={ref}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="royalblue" />
    </mesh>
  );
}

export default function SpinningCube() {
  return (
    <div className="h-64 w-64">
      <Canvas>
        <ambientLight />
        <Box />
      </Canvas>
    </div>
  );
}
