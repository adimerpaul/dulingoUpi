/* ===== Lógica de login y registro ===== */

// Si ya hay sesión, ir directo al app
if (localStorage.getItem('lumo_token')) {
  window.location.href = './app.html';
}

function showError(msg) {
  const el = document.getElementById('error-msg');
  if (el) el.textContent = msg;
}

function setLoading(form, loading) {
  const btn = form.querySelector('button[type="submit"]');
  if (!btn) return;
  btn.textContent = loading ? 'Cargando…' : btn.dataset.label;
  btn.disabled = loading;
}

// ---- LOGIN ----
const loginForm = document.getElementById('login-form');
if (loginForm) {
  const btn = loginForm.querySelector('button[type="submit"]');
  btn.dataset.label = btn.textContent;

  loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    showError('');
    setLoading(loginForm, true);
    try {
      const res = await api.auth.login(loginForm.email.value, loginForm.password.value);
      localStorage.setItem('lumo_token', res.data.token);
      localStorage.setItem('lumo_user',  JSON.stringify(res.data.user));
      window.location.href = './app.html';
    } catch (err) {
      showError(err.message || 'Error al iniciar sesión');
      setLoading(loginForm, false);
    }
  });
}

// ---- REGISTER ----
const registerForm = document.getElementById('register-form');
if (registerForm) {
  const btn = registerForm.querySelector('button[type="submit"]');
  btn.dataset.label = btn.textContent;

  registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    showError('');
    const pass  = registerForm.password.value;
    const pass2 = registerForm.password2?.value;
    if (pass2 !== undefined && pass !== pass2) {
      return showError('Las contraseñas no coinciden');
    }
    setLoading(registerForm, true);
    try {
      const res = await api.auth.register(
        registerForm.nombre.value,
        registerForm.email.value,
        pass
      );
      localStorage.setItem('lumo_token', res.data.token);
      localStorage.setItem('lumo_user',  JSON.stringify(res.data.user));
      window.location.href = './app.html';
    } catch (err) {
      showError(err.message || 'Error al registrarse');
      setLoading(registerForm, false);
    }
  });
}
