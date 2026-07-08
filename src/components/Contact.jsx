import { GitHubIcon, LinkedInIcon, MailIcon } from './icons.jsx';

export default function Contact() {
  return (
    <section id="contact" className="max-w-3xl mx-auto px-6 py-28 text-center">
      <p className="reveal mono text-accent mb-3">04. What's Next?</p>
      <h2 className="reveal section-heading text-4xl font-bold text-white mb-6">Let's Work Together</h2>
      <p className="reveal text-slate-400 mb-10">
        Looking for a software developer for a project? I'm available for flexible, project-based work —
        send me a message and let's talk about what you need.
      </p>
      <a
        href="mailto:alperensamil05@gmail.com"
        className="reveal inline-block px-8 py-3 rounded-full bg-accent text-ink font-semibold hover:bg-accent/80 transition-colors"
      >
        Say Hello
      </a>
      <div className="reveal flex items-center justify-center gap-6 mt-10 text-slate-400">
        <a href="https://github.com/alperensamilx" target="_blank" rel="noopener" className="hover:text-accent transition-colors">
          <GitHubIcon />
        </a>
        <a href="https://www.linkedin.com/in/alperen-şamil-ilmaz-91857219a/" target="_blank" rel="noopener" className="hover:text-accent transition-colors">
          <LinkedInIcon />
        </a>
        <a href="mailto:alperensamil05@gmail.com" className="hover:text-accent transition-colors">
          <MailIcon />
        </a>
      </div>
    </section>
  );
}
