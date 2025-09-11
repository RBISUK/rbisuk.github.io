const fs = require('fs');
const assert = require('assert');

const index = fs.readFileSync('index.html', 'utf8');
assert(
  index.includes('Confidence') && index.includes('Clarity') && index.includes('Compliance'),
  'Home page missing feature cards',
);
['Services','Software','Dashboards','Trust','Legal'].forEach(link=>{
  assert(index.includes(`>${link}<`), `Nav missing ${link} link`);
});

const dashboards = fs.readFileSync('dashboards.html', 'utf8');
assert(/\d/.test(dashboards), 'Dashboards page should include numeric industry data');

console.log('All tests passed.');

