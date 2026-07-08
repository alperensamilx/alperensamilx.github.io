export default function Footer() {
  return (
    <footer className="border-t border-white/5 py-8 text-center">
      <p className="mono text-sm text-slate-400">Designed &amp; built by Alperen Şamil İlmaz</p>
      <p className="mono text-xs text-slate-600 mt-1">© {new Date().getFullYear()}</p>
    </footer>
  );
}
