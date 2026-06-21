// Admin logic
document.addEventListener('DOMContentLoaded', () => {
    
    window.deleteProduct = async (id) => {
        const confirm = await confirmAction('¿Seguro que deseas eliminar este producto?');
        if (confirm) {
            try {
                await apiDelete(`/products/${id}`);
                showToast('Producto eliminado');
                window.location.reload();
            } catch (e) { }
        }
    };

    window.saveSettings = async (form) => {
        event.preventDefault();
        const data = Object.fromEntries(new FormData(form));
        try {
            await apiPut('/config', data);
            showToast('Configuración guardada');
        } catch(e) {}
    };

    // Color pickers sync
    $$('.color-input input[type="color"]').forEach(picker => {
        picker.addEventListener('input', (e) => {
            const textInput = e.target.nextElementSibling;
            if(textInput) textInput.value = e.target.value;
            // Live preview
            document.documentElement.style.setProperty(`--color-${e.target.name.replace('_color', '')}`, e.target.value);
        });
    });
});
