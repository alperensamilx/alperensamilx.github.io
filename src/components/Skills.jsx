const GROUPS = [
  { title: 'Backend', skills: ['Python', 'Django', 'Django REST Framework', 'PostgreSQL / SQLite'] },
  { title: 'Data', skills: ['pandas', 'matplotlib', 'Data cleaning & analysis'] },
  { title: 'Web', skills: ['HTML/CSS', 'JavaScript', 'React', 'REST API design'] },
  { title: 'Tooling', skills: ['Git / GitHub', 'Docker', 'Automated testing', 'CI/CD'] },
];

export default function Skills() {
  return (
    <section id="skills" className="max-w-6xl mx-auto px-6 py-28">
      <h2 className="reveal section-heading text-2xl font-bold text-white mb-3">
        <span className="mono text-accent mr-2">02.</span>Skills
      </h2>
      <p className="reveal text-slate-400 mb-10">Tools and technologies I use to ship real, working software.</p>
      <div className="grid sm:grid-cols-2 gap-6">
        {GROUPS.map((group) => (
          <div key={group.title} className="reveal bg-white/5 border border-white/10 rounded-xl p-6">
            <h3 className="font-display font-semibold text-white mb-4">
              <span className="text-accent mr-1">▹</span>
              {group.title}
            </h3>
            <div className="flex flex-wrap gap-2">
              {group.skills.map((skill) => (
                <span key={skill} className="text-xs mono px-3 py-1 rounded-full bg-accent/10 text-accent">
                  {skill}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
