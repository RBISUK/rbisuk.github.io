document.addEventListener('DOMContentLoaded', () => {
  const ctx = document.getElementById('industryChart');
  if (!ctx) return;
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['Energy', 'Cybersecurity', 'Finance', 'Retail'],
      datasets: [{
        data: [101.7, 4.45, 5.2, 19],
        backgroundColor: ['#1c2541', '#3a506b', '#5bc0be', '#0b132b']
      }]
    },
    options: {
      scales: {
        y: { beginAtZero: true }
      },
      plugins: { legend: { display: false } }
    }
  });
});
