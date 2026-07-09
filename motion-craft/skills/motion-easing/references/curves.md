# Easing Curve Catalogue

## Use-case → curve mapping

| Use case | Curve family | CSS cubic-bezier | GSAP ease | Remotion |
|---|---|---|---|---|
| UI element enter | ease-out | `cubic-bezier(0.0,0.0,0.2,1)` | `power2.out` | `Easing.out(Easing.cubic)` |
| UI element exit | ease-in | `cubic-bezier(0.4,0.0,1,1)` | `power2.in` | `Easing.in(Easing.cubic)` |
| Modal / overlay in | ease-out (soft) | `cubic-bezier(0.16,1,0.3,1)` | `expo.out` | `Easing.out(Easing.exp)` |
| Logo pop / stamp | overshoot | — | `back.out(1.7)` | low-damping `spring({config:{damping:12,mass:0.6,stiffness:120}})` |
| Number counter | ease-out | `cubic-bezier(0.0,0.0,0.2,1)` | `power1.out` | `Easing.out(Easing.quad)` |
| Camera / pan move | ease-in-out | `cubic-bezier(0.4,0.0,0.2,1)` | `power2.inOut` | `Easing.inOut(Easing.cubic)` |
| Looping rotation / marquee | linear (legit) | `linear` | `none` | linear `interpolate` |

## GSAP quick list — "use when"

- `power2.out` — default entrance; clean, unfussy.
- `power3.out` — stronger settle; a bit more drama on arrival.
- `expo.out` — very fast in, long soft tail; premium modal/overlay feel.
- `back.out(1.7)` — overshoot pop; logos, badges, playful stamps. Raise the number for more overshoot.
- `elastic.out(1, 0.3)` — bouncy, springy; use sparingly, reads as toy-like if overused.

## Reading a cubic-bezier

`cubic-bezier(x1, y1, x2, y2)` — the two control points. y climbs faster than x early = fast start (ease-in); y lags x early then catches up = slow start (ease-out). Keep x1 and x2 in [0,1]; y values may exceed 1 to create overshoot.
