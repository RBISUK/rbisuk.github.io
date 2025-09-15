import { spawn } from 'node:child_process';
import { setTimeout as wait } from 'node:timers/promises';
const PORT = process.env.PORT || '3001';
const BASE = `http://127.0.0.1:${PORT}`;

function run(cmd, args, opts={}) {
  return new Promise((res, rej) => {
    const p = spawn(cmd, args, { stdio: 'inherit', shell: true, ...opts });
    p.on('exit', (code) => code === 0 ? res() : rej(new Error(`${cmd} ${args.join(' ')} → ${code}`)));
  });
}
async function get(path) {
  const r = await fetch(`${BASE}${path}`, { redirect: 'follow' });
  const text = await r.text();
  return { status: r.status, text };
}

(async () => {
  await run('npm', ['run', '-s', 'typecheck']);
  await run('npm', ['run', '-s', 'build']);
  const dev = spawn('npm', ['run', '-s', 'dev:port'], { env: { ...process.env, PORT }, shell: true });

  let ok = false;
  for (let i = 0; i < 60; i++) {
    try { const r = await fetch(`${BASE}`, { redirect: 'follow' }); if (r.ok) { ok = true; break; } } catch {}
    await wait(700);
  }
  if (!ok) { dev.kill('SIGKILL'); throw new Error('Dev server failed to start'); }

  const checks = [
    ['/', /RBIS — Main/i],
    ['/main', /RBIS — Main/i],
    ['/hdr', /HDR Funnel/i],
    ['/hdr/pricing', /(Pricing)/i],
    ['/hdr/what-it-does', /(What it does)/i],
    ['/hdr/trust', /(Trust)/i],
    ['/hdr/value', /(Value)/i],
    ['/main/value', /(RBIS Value|Value)/i],
  ];

  let failed = false;
  for (const [path, regex] of checks) {
    const { status, text } = await get(path);
    if (status !== 200 || !regex.test(text)) {
      console.error(`[FAIL] ${path} status=${status} regex=${regex}`);
      failed = true;
    } else {
      console.log(`[OK] ${path}`);
    }
  }
  dev.kill('SIGKILL');
  if (failed) process.exit(1);
  console.log('SMOKE PASS');
})();
