const fs = require('fs');
const assert = require('assert');

const html = fs.readFileSync('index.html', 'utf8');
['RBIS UK', 'Services', 'Solutions', 'Contact'].forEach(text => {
  assert(html.includes(text), `${text} missing from index.html`);
});

['main.ts', 'main.js'].forEach(file => {
  assert(fs.existsSync(file), `${file} is missing`);
});

console.log('All tests passed.');
