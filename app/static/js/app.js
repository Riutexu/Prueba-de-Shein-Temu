document.addEventListener('DOMContentLoaded', () => {
    // Mobile sidebar toggle for admin
    const sidebarToggle = $('#admin-toggle');
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', () => {
            const sidebar = $('.admin-sidebar');
            if (sidebar) {
                if (sidebar.style.display === 'flex') {
                    sidebar.style.display = '';
                } else {
                    sidebar.style.display = 'flex';
                    sidebar.style.position = 'fixed';
                    sidebar.style.top = '0';
                    sidebar.style.bottom = '0';
                    sidebar.style.left = '0';
                    sidebar.style.zIndex = '1000';
                }
            }
        });
    }

    // Highlighting active admin nav link
    const path = window.location.pathname;
    $$('.admin-sidebar__link').forEach(link => {
        if (link.getAttribute('href') === path) {
            link.classList.add('admin-sidebar__link--active');
        }
    });
});
