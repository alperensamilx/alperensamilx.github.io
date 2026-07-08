import ProjectCard from './ProjectCard.jsx';

const PROJECTS = [
  {
    name: 'OrderLens',
    overline: 'Featured Project',
    description:
      'A multi-user Django web app for e-commerce sellers: upload a raw order-export CSV, map its columns (auto-detected), and get an instant KPI dashboard — revenue, AOV, repeat-customer rate — plus charts. Async analysis via Celery, REST API, Docker + CI.',
    tech: ['Django', 'DRF', 'Celery', 'pandas', 'Docker'],
    github: 'https://github.com/alperensamilx/orderlens',
    demo: 'https://orderlens-xkef.onrender.com',
    image: null,
  },
  {
    name: 'PulseCheck',
    overline: 'Uptime Monitoring',
    description:
      'A self-hosted alternative to UptimeRobot: pings your URLs on a schedule, auto-opens/closes incidents on state change with email alerts, and publishes a public status page + JSON API per organization.',
    tech: ['Django', 'Celery', 'Redis', 'DRF', 'Docker'],
    github: 'https://github.com/alperensamilx/pulsecheck',
    demo: 'https://pulsecheck-kky7.onrender.com',
    image: null,
  },
  {
    name: 'JobFit AI',
    overline: 'LLM-Powered',
    description:
      'Upload a CV (PDF) and a job posting — an LLM (Llama 3.3 70B via Groq) compares the two via structured tool-calling and returns a fit score, strengths, and missing skills. The PDF itself is never stored, only its extracted text.',
    tech: ['Django', 'Groq API', 'pypdf'],
    github: 'https://github.com/alperensamilx/jobfit-ai',
    demo: 'https://jobfit-ai-0n3m.onrender.com',
    image: null,
  },
];

export default function Projects() {
  return (
    <section id="projects" className="max-w-6xl mx-auto px-6 py-28">
      <h2 className="reveal section-heading text-2xl font-bold text-white mb-3">
        <span className="mono text-accent mr-2">03.</span>Projects
      </h2>
      <p className="reveal text-slate-400 mb-10">A look at what I've built recently.</p>
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8" style={{ perspective: '1200px' }}>
        {PROJECTS.map((project) => (
          <ProjectCard key={project.name} project={project} />
        ))}
      </div>
    </section>
  );
}
