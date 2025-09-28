#!/usr/bin/env bash
set -e

# Move to app dir
cd /var/app/current

# Make sure we use the app's virtualenv Python
PYTHON=$(which python || which python3)

# Run migrations
$PYTHON manage.py migrate --noinput

# Create or update the superuser using EB env vars
# (DJANGO_SUPERUSER_USERNAME, DJANGO_SUPERUSER_EMAIL, DJANGO_SUPERUSER_PASSWORD)
$PYTHON manage.py shell <<'PYCODE'
import os
from django.contrib.auth import get_user_model

username = os.environ.get("DJANGO_SUPERUSER_USERNAME", "admin")
email    = os.environ.get("DJANGO_SUPERUSER_EMAIL", "nicholassilvasantosrj@gmail.com")
password = os.environ.get("DJANGO_SUPERUSER_PASSWORD", "SomeStrongPass123")

User = get_user_model()
u, created = User.objects.get_or_create(username=username, defaults={
    "email": email, "is_staff": True, "is_superuser": True, "is_active": True
})
if not created:
    # make sure it has staff/superuser and update email
    changed = False
    if not u.is_staff: u.is_staff = True; changed = True
    if not u.is_superuser: u.is_superuser = True; changed = True
    if email and u.email != email: u.email = email; changed = True
    if changed: u.save()

if password:
    u.set_password(password)
    u.save()
print(f"Superuser ready: {u.username} / {u.email}")
PYCODE
