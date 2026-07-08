const JOURNEY = [
  { title: 'Architecture Student', desc: 'Studied architecture before switching paths into software.' },
  { title: 'Data Scientist — Italy', desc: 'Built data pipelines and tools with Python/Django, remotely.' },
  { title: 'Licensed Pilot', desc: 'Completed pilot training; now licensed and job-hunting in aviation.' },
  { title: 'Full-Stack Developer', desc: 'Back to building — Django, REST APIs, data-driven web apps.' },
];

export default function About() {
  return (
    <section id="about" className="max-w-6xl mx-auto px-6 py-28">
      <h2 className="reveal section-heading text-2xl font-bold text-white mb-10">
        <span className="mono text-accent mr-2">01.</span>About Me
      </h2>
      <div className="grid md:grid-cols-2 gap-12">
        <div className="reveal space-y-4 text-slate-300 leading-relaxed">
          <p>
            I left architecture school to move into software, then worked as a Data Scientist (Python/Django)
            for a company in Italy. I later trained as a pilot and am now licensed — a detour that taught me
            discipline and how to work with complex systems, which I'm now bringing back to software.
          </p>
          <p>
            I currently build Django web applications, data analysis tools, and REST APIs for small
            businesses and e-commerce sellers. My recent project, <strong className="text-white">OrderLens</strong>,
            is a full web app where sellers upload raw order CSVs and get an instant sales/customer analytics
            dashboard — complete with auth and a REST API.
          </p>
          <p>If you're looking for a developer for project-based, flexible work, let's talk.</p>
        </div>
        <ul className="reveal space-y-6">
          {JOURNEY.map((step) => (
            <li key={step.title} className="border-l-2 border-accent/40 pl-4">
              <div className="font-display font-semibold text-white">{step.title}</div>
              <div className="text-sm text-slate-400 mt-1">{step.desc}</div>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
