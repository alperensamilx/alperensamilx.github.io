# Portfolio Site

My personal portfolio site — React + Vite + Three.js (react-three-fiber), deployed to GitHub Pages as `alperensamilx.github.io`.

A mouse-reactive 3D hero scene, GSAP ScrollTrigger-driven reveal animations, and a mouse-tilt project gallery showcasing OrderLens, PulseCheck, and JobFit AI.

## Structure

```
src/
  components/
    Hero3D.jsx / HeroScene.jsx   # Canvas + R3F scene (distorted mesh, sparkles, mouse parallax)
    TiltCard.jsx                 # mouse-tilt wrapper used by project cards
    Nav.jsx, Hero.jsx, About.jsx, Skills.jsx, Projects.jsx, ProjectCard.jsx, Contact.jsx, Footer.jsx
  hooks/
    useScrollReveal.js           # GSAP ScrollTrigger .reveal animation, refreshes after images load
public/assets/                   # project screenshots
```

## Local development

```bash
npm install
npm run dev
```

Visit `http://localhost:5173`.

## Build

```bash
npm run build
npm run preview   # serve the production build locally to sanity-check it
```

## Deployment

`.github/workflows/deploy.yml` builds the site and publishes `dist/` to GitHub Pages via `actions/deploy-pages` on every push to `main`. In the repo's **Settings → Pages**, set the source to "GitHub Actions" (not a branch) for this to take effect.

## To update

- Add a new project to the `PROJECTS` array in `src/components/Projects.jsx` as new projects are finished.
- No LinkedIn link is included yet — add one in `src/components/Contact.jsx` and `src/components/icons.jsx` once you have a profile URL.
