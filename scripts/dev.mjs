import { spawn } from 'node:child_process';

const port = process.env.PORT?.toString() || '3000';

// Show what we're doing (useful in CI logs)
console.log(`[dev.mjs] Starting Next on port ${port}`);

const child = spawn('npx', ['next', 'dev', '-p', port], {
  stdio: 'inherit',
  shell: true,
  env: { ...process.env, PORT: port }
});

child.on('exit', (code) => {
  process.exit(code ?? 1);
});
