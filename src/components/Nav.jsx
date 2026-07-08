import { useState } from 'react';

const LINKS = [
  { href: '#about', label: 'About', num: '01' },
  { href: '#skills', label: 'Skills', num: '02' },
  { href: '#projects', label: 'Projects', num: '03' },
  { href: '#contact', label: 'Contact', num: '04' },
];

export default function Nav() {
  const [open, setOpen] = useState(false);

  return (
    <nav className="fixed top-0 inset-x-0 z-50 backdrop-blur bg-ink/70 border-b border-white/5">
      <div className="max-w-6xl mx-auto px-6 flex items-center justify-between h-16">
        <a href="#top" className="font-display text-xl font-bold text-white">
          A<span className="text-accent">.</span>
        </a>

        <button
          className="md:hidden flex flex-col gap-1.5 p-2"
          aria-label="Toggle menu"
          onClick={() => setOpen((o) => !o)}
        >
          <span className="w-6 h-0.5 bg-white" />
          <span className="w-6 h-0.5 bg-white" />
          <span className="w-6 h-0.5 bg-white" />
        </button>

        <div className="hidden md:flex items-center gap-8">
          {LINKS.map((link) => (
            <a key={link.href} href={link.href} className="text-sm text-slate-300 hover:text-accent transition-colors">
              <span className="mono text-accent mr-1">{link.num}.</span>
              {link.label}
            </a>
          ))}
        </div>
      </div>

      {open && (
        <div className="md:hidden flex flex-col gap-4 px-6 pb-6 bg-ink/95">
          {LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="text-sm text-slate-300"
              onClick={() => setOpen(false)}
            >
              <span className="mono text-accent mr-1">{link.num}.</span>
              {link.label}
            </a>
          ))}
        </div>
      )}
    </nav>
  );
}
