const fs = require('fs');
const assert = require('assert');

const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
['next', 'react', 'react-dom', 'typescript', 'tailwindcss'].forEach(dep => {
  const present = (pkg.dependencies && pkg.dependencies[dep]) || (pkg.devDependencies && pkg.devDependencies[dep]);
  assert(present, `${dep} not listed in package.json`);
});

['tsconfig.json', 'next.config.mjs', 'tailwind.config.ts', 'app/page.tsx', 'app/layout.tsx'].forEach(file => {
  assert(fs.existsSync(file), `${file} is missing`);
});

const page = fs.readFileSync('app/page.tsx', 'utf8');
assert(page.includes('RBIS UK'), 'Landing page missing heading');

console.log('All tests passed.');
