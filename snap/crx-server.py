import http.server
from http.server import HTTPServer, BaseHTTPRequestHandler
import socketserver
import os

PORT = 8088

os.chdir('/var/www')

Handler = http.server.SimpleHTTPRequestHandler

Handler.extensions_map={
	'.crx':	'application/x-chrome-extension',
        '.xml': 'application/xml',
	'': 'application/octet-stream', # Default
    }

httpd = socketserver.TCPServer(("", PORT), Handler)

print("serving at port", PORT)
httpd.serve_forever()
