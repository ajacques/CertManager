export default function debounce(func, wait, immediate, maxWait) {
  let timeout;
  maxWait = maxWait || 30 * 1000;
  let lastTrigger = null;
  return function() {
    const now = new Date();
    const context = this;
    const args = arguments;
    if (lastTrigger !== null && now - lastTrigger > maxWait) {
      func.apply(context, args);
      lastTrigger = new Date();
    }
    clearTimeout(timeout);
    timeout = setTimeout(function() {
      timeout = null;
      if (!immediate) {
        func.apply(context, args);
        lastTrigger = new Date();
      }
    }, wait);
    if (immediate && !timeout) {
      func.apply(context, args);
      lastTrigger = new Date();
    }
  };
}
