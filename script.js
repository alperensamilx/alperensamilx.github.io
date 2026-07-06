document.getElementById('year').textContent = new Date().getFullYear();

// Mobile nav toggle
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.getElementById('navLinks');
navToggle.addEventListener('click', () => navLinks.classList.toggle('open'));
navLinks.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => navLinks.classList.remove('open'));
});

// Scroll progress bar
const progressBar = document.getElementById('progressBar');
function updateProgress() {
    const scrollTop = window.scrollY;
    const docHeight = document.documentElement.scrollHeight - window.innerHeight;
    const pct = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
    progressBar.style.width = pct + '%';
}
window.addEventListener('scroll', updateProgress, { passive: true });
updateProgress();

// Reveal on scroll
const revealEls = document.querySelectorAll('.reveal');
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            entry.target.classList.add('in-view');
            revealObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.15 });
revealEls.forEach((el) => revealObserver.observe(el));

// Project screenshot tabs
const shotTabs = document.querySelectorAll('.shot-tab');
const shots = document.querySelectorAll('.shot');
shotTabs.forEach((tab) => {
    tab.addEventListener('click', () => {
        const target = tab.dataset.target;
        shotTabs.forEach((t) => t.classList.remove('active'));
        shots.forEach((s) => s.classList.remove('active'));
        tab.classList.add('active');
        document.querySelector(`.shot[data-shot="${target}"]`).classList.add('active');
    });
});

// Active nav link highlighting
const sections = document.querySelectorAll('main section[id], header[id]');
const navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');
const navObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
        if (entry.isIntersecting) {
            const id = entry.target.getAttribute('id');
            navAnchors.forEach((a) => {
                a.classList.toggle('active-link', a.getAttribute('href') === `#${id}`);
            });
        }
    });
}, { rootMargin: '-50% 0px -50% 0px' });
sections.forEach((s) => navObserver.observe(s));
