import TiltCard from './TiltCard.jsx';
import { GitHubIcon } from './icons.jsx';

export default function ProjectCard({ project }) {
  return (
    <TiltCard className="reveal">
      <div className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden h-full flex flex-col">
        {project.image ? (
          <div className="aspect-video overflow-hidden border-b border-white/10">
            <img src={project.image} alt={project.name} className="w-full h-full object-cover" style={{ transform: 'translateZ(20px)' }} />
          </div>
        ) : (
          <div className="aspect-video flex items-center justify-center border-b border-white/10 bg-gradient-to-br from-accent/20 to-indigo-500/10">
            <span className="font-display text-4xl font-bold text-accent/60">{project.name}</span>
          </div>
        )}
        <div className="p-6 flex flex-col flex-1">
          <p className="mono text-xs text-accent mb-1">{project.overline}</p>
          <h3 className="font-display text-xl font-bold text-white mb-3">{project.name}</h3>
          <p className="text-sm text-slate-300 leading-relaxed flex-1">{project.description}</p>
          <div className="flex flex-wrap gap-2 my-4">
            {project.tech.map((t) => (
              <span key={t} className="text-xs mono px-2.5 py-1 rounded-full bg-white/5 text-slate-400">
                {t}
              </span>
            ))}
          </div>
          <div className="flex items-center gap-4 mt-auto">
            <a
              href={project.github}
              target="_blank"
              rel="noopener"
              className="inline-flex items-center gap-2 text-sm text-white hover:text-accent transition-colors"
            >
              <GitHubIcon width={16} height={16} /> Code
            </a>
            {project.demo && (
              <a
                href={project.demo}
                target="_blank"
                rel="noopener"
                className="text-sm text-accent hover:underline"
              >
                Live Demo ↗
              </a>
            )}
          </div>
        </div>
      </div>
    </TiltCard>
  );
}
