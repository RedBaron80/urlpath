from django.http import HttpResponse
from urlpath import getUrlPath

def index(request):
    url = request.build_absolute_uri()
    # Using Django's request.get_full_path() would also work
    path=getUrlPath(url)
    print (path)
    return HttpResponse(path)