import Hero3D from './Hero3D.jsx';

export default function Hero() {
  return (
    <header id="top" className="relative min-h-screen flex items-center overflow-hidden">
      <Hero3D />
      <div className="relative max-w-6xl mx-auto px-6 pt-16">
        <p className="mono text-accent reveal">Hi, my name is</p>
        <h1 className="reveal font-display text-5xl sm:text-7xl font-bold text-white mt-3">
          Alperen Şamil İlmaz.
        </h1>
        <h2 className="reveal font-display text-3xl sm:text-5xl font-bold text-slate-400 mt-2">
          I build backend systems that turn messy data into clear decisions.
        </h2>
        <p className="reveal text-slate-300 max-w-xl mt-6 leading-relaxed">
          Software developer building web applications, data analysis tools, and REST APIs
          for small businesses and e-commerce sellers.
        </p>
        <div className="reveal flex flex-wrap gap-4 mt-8">
          <a
            href="#projects"
            className="px-6 py-3 rounded-full bg-accent text-ink font-semibold hover:bg-accent/80 transition-colors"
          >
            View My Work
          </a>
          <a
            href="#contact"
            className="px-6 py-3 rounded-full border border-accent text-accent font-semibold hover:bg-accent/10 transition-colors"
          >
            Get in Touch
          </a>
        </div>
      </div>
    </header>
  );
}
