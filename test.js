const fs = require('fs');
const assert = require('assert');

const index = fs.readFileSync('index.html', 'utf8');
assert(index.includes('class="brand">RBIS</a>'), 'Nav missing RBIS brand link');
assert(
  index.includes('Confidence') && index.includes('Clarity') && index.includes('Compliance'),
  'Home page missing feature cards',
);
assert(index.includes('Explore Services'), 'Home page missing call to action');
['Services','Dashboards','Software','Trust','Legal'].forEach(link=>{
  assert(index.includes(`>${link}<`), `Nav missing ${link} link`);
});

const dashboards = fs.readFileSync('dashboards.html', 'utf8');
assert(/\d/.test(dashboards), 'Dashboards page should include numeric industry data');

const legal = fs.readFileSync('legal.html', 'utf8');
assert(legal.includes('openHash'), 'Legal page missing hash anchor handler');

const style = fs.readFileSync('style.css', 'utf8');
assert(style.includes(':target{scroll-margin-top'), 'Missing scroll-margin for anchored sections');

console.log('All tests passed.');

