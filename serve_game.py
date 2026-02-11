#!/usr/bin/env python3
"""
Simple HTTP server to serve the tennis game on localhost
Run this and open http://localhost:8000/tennis_game.html in Safari
"""

import http.server
import socketserver
import socket

PORT = 8000

def get_local_ip():
    """Get the local IP address"""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "localhost"

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

if __name__ == "__main__":
    Handler = MyHTTPRequestHandler

    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        local_ip = get_local_ip()
        print("=" * 60)
        print(f"Tennis Game Server Running!")
        print("=" * 60)
        print(f"\nOn this computer, open:")
        print(f"  http://localhost:{PORT}/tennis_game.html")
        print(f"\nOn your iPhone (same WiFi network), open Safari and go to:")
        print(f"  http://{local_ip}:{PORT}/tennis_game.html")
        print(f"\nPress Ctrl+C to stop the server")
        print("=" * 60)
        httpd.serve_forever()
