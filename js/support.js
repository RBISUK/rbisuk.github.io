document.addEventListener('DOMContentLoaded', () => {
  const btn = document.createElement('a');
  btn.textContent = 'Get Rapid Support';
  btn.className = 'support-btn';
  btn.href = window.location.pathname.includes('/services/') || window.location.pathname.includes('/solutions/') ? '../contact.html' : 'contact.html';
  document.body.appendChild(btn);
});
