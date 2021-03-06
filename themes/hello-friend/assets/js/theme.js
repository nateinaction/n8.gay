// Toggle theme dark mode
function enableDarkMode(enable) {
  document.body.classList.toggle("dark-theme", enable);
}

// On page load, set the theme
if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
  enableDarkMode(true);
} else {
  enableDarkMode(false);
}

// On system change, update the theme
window.matchMedia('(prefers-color-scheme: dark)')
      .addEventListener('change', event => {
  if (event.matches) {
    enableDarkMode(true);
  } else {
    enableDarkMode(false);
  }
})
