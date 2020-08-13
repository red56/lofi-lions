// based on https://codepen.io/vsync/pen/czgrf

function autoexpandTextarea(el) {
  setTimeout(function () {
    el.style.cssText = 'height:auto; padding:0';
    // for box-sizing other than "content-box" use:
    // el.style.cssText = '-moz-box-sizing:content-box';
    el.style.cssText = 'height:' + el.scrollHeight + 'px';
  }, 0);
}

function autoexpandTextareaInit() {
  document.querySelectorAll('.js-autoexpand-textarea textarea').forEach(function (textarea) {
    textarea.addEventListener('keydown', function () {
      autoexpandTextarea(textarea);
    });
    autoexpandTextarea(textarea);
  });
}
document.addEventListener('DOMContentLoaded', autoexpandTextareaInit, false);


