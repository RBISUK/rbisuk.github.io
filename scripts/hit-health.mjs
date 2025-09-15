const url = process.env.URL || "http://localhost:3000/api/health";
fetch(url).then(r=>r.json()).then(j=>console.log(j)).catch(e=>{console.error(e); process.exit(1);});
