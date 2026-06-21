const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => document.querySelectorAll(selector);

const debounce = (fn, delay) => {
    let timeoutId;
    return (...args) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn(...args), delay);
    };
};

const formatCurrency = (amount, symbol, code) => {
    return `${symbol}${parseFloat(amount).toFixed(2)}`;
};

const generateSlug = (text) => {
    return text.toString().toLowerCase()
        .replace(/\s+/g, '-')           // Replace spaces with -
        .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
        .replace(/\-\-+/g, '-')         // Replace multiple - with single -
        .replace(/^-+/, '')             // Trim - from start of text
        .replace(/-+$/, '');            // Trim - from end of text
};

const escapeHtml = (unsafe) => {
    return (unsafe || "").toString()
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
};

const showToast = (message, type = 'success', duration = 3000) => {
    const container = $('#toast-container');
    if (!container) return;
    
    const toast = document.createElement('div');
    toast.className = `toast toast--${type}`;
    toast.textContent = message;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 300);
    }, duration);
};

const showModal = (htmlContent) => {
    const container = $('#modal-container');
    if (!container) return;
    
    container.innerHTML = `
        <div class="modal-overlay" onclick="if(event.target===this) hideModal()">
            <div class="modal">
                ${htmlContent}
            </div>
        </div>
    `;
    document.body.style.overflow = 'hidden';
};

const hideModal = () => {
    const container = $('#modal-container');
    if (container) container.innerHTML = '';
    document.body.style.overflow = '';
};

const confirmAction = (message) => {
    return new Promise((resolve) => {
        showModal(`
            <div class="modal__header">
                <h3>Confirmar</h3>
            </div>
            <div class="modal__body">
                <p>${escapeHtml(message)}</p>
            </div>
            <div class="modal__footer">
                <button class="btn btn--ghost" onclick="hideModal(); window.resolveConfirm(false)">Cancelar</button>
                <button class="btn btn--danger" onclick="hideModal(); window.resolveConfirm(true)">Aceptar</button>
            </div>
        `);
        window.resolveConfirm = resolve;
    });
};

const fileToPreview = (file) => {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.onerror = (e) => reject(e);
        reader.readAsDataURL(file);
    });
};

window.$ = $;
window.$$ = $$;
window.debounce = debounce;
window.formatCurrency = formatCurrency;
window.generateSlug = generateSlug;
window.escapeHtml = escapeHtml;
window.showToast = showToast;
window.showModal = showModal;
window.hideModal = hideModal;
window.confirmAction = confirmAction;
window.fileToPreview = fileToPreview;
