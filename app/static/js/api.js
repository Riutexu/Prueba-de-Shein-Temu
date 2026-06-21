const apiFetch = async (endpoint, options = {}) => {
    try {
        const url = `/api/v1${endpoint}`;
        const response = await fetch(url, options);
        const data = await response.json();
        
        if (!response.ok || !data.success) {
            throw new Error(data.error || 'API Error');
        }
        
        return data.data;
    } catch (error) {
        showToast(error.message, 'error');
        throw error;
    }
};

const apiGet = (endpoint, params = {}) => {
    const qs = new URLSearchParams(params).toString();
    const url = qs ? `${endpoint}?${qs}` : endpoint;
    return apiFetch(url);
};

const apiPost = (endpoint, data, isFormData = false) => {
    const options = {
        method: 'POST',
    };
    
    if (isFormData) {
        options.body = data;
    } else {
        options.headers = { 'Content-Type': 'application/json' };
        options.body = JSON.stringify(data);
    }
    
    return apiFetch(endpoint, options);
};

const apiPut = (endpoint, data, isFormData = false) => {
    const options = {
        method: 'PUT',
    };
    if (isFormData) {
        options.body = data;
    } else {
        options.headers = { 'Content-Type': 'application/json' };
        options.body = JSON.stringify(data);
    }
    return apiFetch(endpoint, options);
};

const apiDelete = (endpoint) => {
    return apiFetch(endpoint, { method: 'DELETE' });
};

window.apiFetch = apiFetch;
window.apiGet = apiGet;
window.apiPost = apiPost;
window.apiPut = apiPut;
window.apiDelete = apiDelete;
