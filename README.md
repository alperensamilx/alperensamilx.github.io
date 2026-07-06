# Portfolio Site

My personal portfolio site — plain HTML/CSS/JS, no backend. Built to be hosted on GitHub Pages as `alperensamilx.github.io`.

## Structure

```
index.html    # the whole page (hero, about, skills, projects, contact)
styles.css
script.js     # mobile menu toggle, scroll reveal, project screenshot tabs
assets/       # project screenshots
```

## To update

- The LinkedIn link in `index.html` (currently `href="#"`) — replace with your own LinkedIn profile link
- Add a new `.project-card` to the `Projects` section as new projects are finished

## Local preview

```bash
python3 -m http.server 8080
```

Visit `http://localhost:8080`.
