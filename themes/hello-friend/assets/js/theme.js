// Use system dark mode
window.matchMedia('(prefers-color-scheme: dark)')
      .addEventListener('change', event => {
  if (event.matches) {
    document.body.classList.toggle("dark-theme", "dark");
  } else {
    document.body.classList.toggle("dark-theme", "light");
  }
})
