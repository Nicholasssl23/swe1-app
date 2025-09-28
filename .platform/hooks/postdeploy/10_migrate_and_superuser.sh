#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="/var/app/current"
# Find EB's virtualenv bin dir (name changes every deploy)
VENV_BIN="$(ls -d /var/app/venv/*/bin | head -n1)"

if [[ -z "${VENV_BIN:-}" || ! -x "$VENV_BIN/python" ]]; then
  echo "ERROR: EB virtualenv python not found under /var/app/venv/*/bin" >&2
  exit 1
fi

export PATH="$VENV_BIN:$PATH"
export DJANGO_SETTINGS_MODULE="mysite.mysite.settings"

cd "$APP_DIR"

python -V

# DB migrations
python manage.py migrate --noinput

# (optional) collect static if you serve via WhiteNoise
python manage.py collectstatic --noinput || true

# Create/update superuser idempotently
python manage.py shell <<'PY'
from django.contrib.auth import get_user_model
User = get_user_model()
email = "nicholassilvasantosrj@gmail.com"
username = "admin"
password = "ChangeMe_Once_Logged_In_123"

u, created = User.objects.get_or_create(username=username, defaults={"email": email})
if created:
    u.set_password(password)
    u.is_superuser = True
    u.is_staff = True
    u.save()
    print("Superuser created:", username, email)
else:
    print("Superuser already exists:", username)
PY
