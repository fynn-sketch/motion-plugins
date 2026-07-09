---
name: liquid-glass-3d
description: Use when building real 3D glass refraction in three.js — transmission/IOR materials or a custom GLSL refraction shader with chromatic aberration, for the web or a headless reel. Documents both approaches with trade-offs.
---

# Liquid Glass 3D (three.js)

Real refraction needs three.js and something in the environment to bend. Two approaches, documented equally. Import three via ESM CDN:

```js
import * as THREE from 'https://esm.sh/three';
import { RoomEnvironment } from 'https://esm.sh/three/examples/jsm/environments/RoomEnvironment.js';
```

Apply the **WebGL-headless setup** from `motion-fx-web` (SwiftShader flags, `preserveDrawingBuffer`, frame-driven animation, render-complete flag) whenever this runs in a reel.

## Approach A — MeshPhysicalMaterial (robust, minimal shader)

```js
const pmrem = new THREE.PMREMGenerator(renderer);
scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture; // something to refract

const glass = new THREE.MeshPhysicalMaterial({
  transmission: 1,      // makes it see-through/refractive
  ior: 1.5,             // index of refraction (glass ≈ 1.5)
  thickness: 1.2,       // volume the light travels through
  roughness: 0.05,      // frost amount
  metalness: 0,
  clearcoat: 1
});
const mesh = new THREE.Mesh(new THREE.IcosahedronGeometry(1, 6), glass);
```
Trade-off: fast, stable, physically plausible; less control over the exact refraction look.

## Approach B — Custom GLSL (full control)

Fragment shader samples an env cube map along the refracted normal, three times at slightly offset IOR for chromatic aberration:

```glsl
uniform samplerCube envMap;
uniform float ior;            // e.g. 1.45
varying vec3 vWorldNormal, vViewDir;

void main() {
  vec3 n = normalize(vWorldNormal);
  vec3 v = normalize(vViewDir);
  // slightly different IOR per channel -> chromatic aberration
  vec3 rR = refract(v, n, 1.0/(ior + 0.02));
  vec3 rG = refract(v, n, 1.0/ ior);
  vec3 rB = refract(v, n, 1.0/(ior - 0.02));
  float r = textureCube(envMap, rR).r;
  float g = textureCube(envMap, rG).g;
  float b = textureCube(envMap, rB).b;
  gl_FragColor = vec4(r, g, b, 1.0);
}
```
Trade-off: total control over the look and the aberration; more code and trickier to get stable under headless software WebGL.

## Which to use

Start with **A** for anything shipping soon; reach for **B** when you need a signature refraction/aberration look that the built-in material can't give.

## Cross-links

`three` (runtime), `motion-fx-web` (headless recipe + fallback to `liquid-glass-2d`).
