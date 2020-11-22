from urllib.parse import urlparse

def removeFirstAndLastSlash(path):
    # removing / at the beggining and at the end if exists
    if path == '/':
        return ''
    pathlist = list(path)
    if pathlist[0] == '/':
        del pathlist[0]
    if pathlist[len(pathlist)-1] == '/':
        del pathlist[len(pathlist)-1]
    return ''.join(pathlist)

def getUrlPath(url):    
    return removeFirstAndLastSlash(urlparse(url).path)
