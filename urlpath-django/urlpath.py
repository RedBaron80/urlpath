from urlpath import getUrlPath
import argparse

def parseArguments():
    # Parsing arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("url")
    args = parser.parse_args()
    return args
   
###########################################################

args = parseArguments()
path = getUrlPath(args.url)

print (path)