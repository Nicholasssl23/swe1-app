from django.contrib import admin
from django.urls import include, path
from django.http import HttpResponse


def home(request):
    return HttpResponse("Hello, World! Django is working on Elastic Beanstalk!")


urlpatterns = [
    path("", home, name="home"),
    path("polls/", include("polls.urls")),  # include the app urls
    path("admin/", admin.site.urls),
]
