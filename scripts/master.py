import http.server
import socketserver
import threading
import os
from zeroconf import ServiceInfo, Zeroconf
import socket

def get_ip_address():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't even have to be reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

class MasterRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/ip':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(self.client_address[0].encode('utf-8'))
        else:
            super().do_GET()

def start_http_server(public_key):
    PORT = 8000
    Handler = MasterRequestHandler
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print("serving at port", PORT)
        # Create a temporary file to serve
        with open("public_key.txt", "w") as f:
            f.write(public_key)
        httpd.serve_forever()

def main():
    # Generate a key pair if one doesn't exist
    if not os.path.exists(os.path.expanduser("~/.ssh/id_rsa.pub")):
        os.system("ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa")

    # Get the public key
    with open(os.path.expanduser("~/.ssh/id_rsa.pub"), "r") as f:
        public_key = f.read()

    # Start the HTTP server in a new thread
    server_thread = threading.Thread(target=start_http_server, args=(public_key,))
    server_thread.daemon = True
    server_thread.start()

    # Register the service with Zeroconf
    zeroconf = Zeroconf()
    ip_address = get_ip_address()
    service_info = ServiceInfo(
        "_http-public-key._tcp.local.",
        "Master Public Key._http-public-key._tcp.local.",
        addresses=[socket.inet_aton(ip_address)],
        port=8000,
        properties={'path': '/public_key.txt'},
        server="master.local.",
    )
    zeroconf.register_service(service_info)

    print("Master SSH key is being published via HTTP and Zeroconf.")
    print("Press Ctrl+C to stop.")

    try:
        while True:
            pass
    except KeyboardInterrupt:
        pass
    finally:
        zeroconf.unregister_service(service_info)
        zeroconf.close()
        # Clean up the temporary file
        if os.path.exists("public_key.txt"):
            os.remove("public_key.txt")

if __name__ == "__main__":
    main()
