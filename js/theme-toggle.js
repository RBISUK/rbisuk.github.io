(function(){
  const STORAGE_KEY = 'rbis_theme';
  const root = document.documentElement;
  const btn = document.getElementById('themeToggle');

  function applyTheme(theme){
    if(theme === 'dark'){
      root.setAttribute('data-theme','dark');
    } else {
      root.removeAttribute('data-theme');
    }
    localStorage.setItem(STORAGE_KEY, theme);
    if(btn){
      btn.textContent = theme === 'dark' ? 'Light Mode' : 'Dark Mode';
      btn.setAttribute('aria-pressed', theme === 'dark');
    }
  }

  const stored = localStorage.getItem(STORAGE_KEY);
  if(stored){
    applyTheme(stored);
  } else if(btn){
    btn.textContent = 'Dark Mode';
    btn.setAttribute('aria-pressed', 'false');
  }

  if(btn){
    btn.addEventListener('click', function(){
      const isDark = root.getAttribute('data-theme') === 'dark';
      applyTheme(isDark ? 'light' : 'dark');
    });
  }
})();
