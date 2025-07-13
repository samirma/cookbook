import time
from zeroconf import ServiceBrowser, Zeroconf
import socket

class MyListener:
    def __init__(self):
        self.info = None

    def remove_service(self, zeroconf, type, name):
        pass

    def add_service(self, zeroconf, type, name):
        self.info = zeroconf.get_service_info(type, name)

def main():
    zeroconf = Zeroconf()
    listener = MyListener()
    browser = ServiceBrowser(zeroconf, "_http-public-key._tcp.local.", listener)

    # Wait for a service to be discovered
    while listener.info is None:
        time.sleep(0.1)

    ip_address = socket.inet_ntoa(listener.info.addresses[0])
    port = listener.info.port
    path = listener.info.properties[b'path'].decode('utf-8')

    print(f"http://{ip_address}:{port}{path}")

    zeroconf.close()

if __name__ == '__main__':
    main()
