
function done(e) {
  var response = document.forms[0].elements;
  var conf = {};

  conf.allow_login = response.allow_login.value;

  conf.licenses = {
    'adobe_acroread':     response['licenses[adobe_acroread]'    ].checked,
    'adobe_flash_plugin': response['licenses[adobe_flash_plugin]'].checked,
  };

  var local_user_errors = document.querySelector('div[id=localuser_errors]');
  local_user_errors.innerHTML = '';
  if (response.localuser_password.value
        !== response.localuser_password_again.value) {
    local_user_errors.innerHTML = 'Passwords do not match.';
    return;
  }

  conf.local_user = {
    admin_rights: response.localuser_admin_rights.checked,
    name:         response.localuser_name.value,
    password:     response.localuser_password.value,
  };

  conf.superlaptop_mode = response.superlaptop_mode.checked;

  process.stdout.write(JSON.stringify(conf) + "\n");
  process.exit(0);
}

document.querySelector('input[id=done_button]')
        .addEventListener('click', done);
