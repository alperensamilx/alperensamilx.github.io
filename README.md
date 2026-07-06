# Portfolio Site

Kişisel portfolyo sitem — plain HTML/CSS/JS, backend yok. GitHub Pages'te `alperensamilx.github.io` adıyla barındırılacak şekilde tasarlandı.

## Yapı

```
index.html    # tüm sayfa (hero, about, skills, projects, contact)
styles.css
script.js     # mobil menü toggle
assets/       # proje ekran görüntüleri
```

## Güncellemesi gerekenler

- `index.html` içinde `#liveDemoLink` — OrderLens Render'a deploy edildikten sonra gerçek URL ile değiştir
- `index.html` içindeki LinkedIn linki (`href="#"`) — kendi LinkedIn profil linkinle değiştir
- Yeni bir proje bitirdikçe `Projects` bölümüne yeni bir `.project-card` ekle

## Yerelde önizleme

```bash
python3 -m http.server 8080
```

`http://localhost:8080` adresine git.
