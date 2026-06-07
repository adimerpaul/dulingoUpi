/* ===== Cliente HTTP para la API Lumo ===== */

const API_BASE = './api';

async function apiCall(path, method = 'GET', body = null) {
  const token = localStorage.getItem('lumo_token');
  const opts = {
    method,
    headers: { 'Content-Type': 'application/json' },
  };
  if (token) opts.headers['Authorization'] = `Bearer ${token}`;
  if (body)  opts.body = JSON.stringify(body);

  const res  = await fetch(`${API_BASE}${path}`, opts);
  const data = await res.json();

  if (res.status === 401) {
    localStorage.removeItem('lumo_token');
    localStorage.removeItem('lumo_user');
    window.location.href = './login.html';
    throw data;
  }

  if (!res.ok) throw data;
  return data;
}

const api = {
  auth: {
    login:    (email, password)          => apiCall('/auth/login',    'POST', { email, password }),
    register: (nombre, email, password)  => apiCall('/auth/register', 'POST', { nombre, email, password }),
  },
  secciones: {
    list:      ()                       => apiCall('/secciones'),
    preguntas: (secId, detalleId)       => apiCall(`/secciones/${secId}/detalles/${detalleId}/preguntas`),
  },
  progreso: {
    get:    ()              => apiCall('/progreso'),
    marcar: (detalleId)     => apiCall('/progreso', 'POST', { seccion_detalle_id: detalleId }),
  },
  admin: {
    list:   (resource)      => apiCall(`/admin/${resource}`),
    update: (resource, id, data) => apiCall(`/admin/${resource}/${id}`, 'PUT', data),
  },
};
