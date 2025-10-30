from django.test import TestCase
from django.urls import reverse


class SmokeTests(TestCase):
    def test_site_renders(self):
        # hits "/" or change to a URL that exists in your app
        resp = self.client.get("/")
        # your root may be a 200 or 400 depending on view; use 200 if you have an index
        self.assertIn(resp.status_code, (200, 302, 301))

    def test_admin_login_page(self):
        resp = self.client.get(reverse("admin:login"))
        self.assertEqual(resp.status_code, 200)
