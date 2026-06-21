document.addEventListener('DOMContentLoaded', () => {
    const searchInput = $('#catalog-search');
    const sortSelect = $('#catalog-sort');
    
    const reloadCatalog = () => {
        const urlParams = new URLSearchParams(window.location.search);
        
        if (searchInput && searchInput.value) {
            urlParams.set('search', searchInput.value);
        } else {
            urlParams.delete('search');
        }
        
        if (sortSelect && sortSelect.value) {
            const [field, dir] = sortSelect.value.split('|');
            urlParams.set('sort_field', field);
            urlParams.set('sort_dir', dir);
        } else {
            urlParams.delete('sort_field');
            urlParams.delete('sort_dir');
        }
        
        urlParams.set('page', 1); // Reset to page 1 on filter
        window.location.search = urlParams.toString();
    };

    if (searchInput) {
        searchInput.addEventListener('input', debounce(reloadCatalog, 800));
    }
    
    if (sortSelect) {
        sortSelect.addEventListener('change', reloadCatalog);
    }
});
