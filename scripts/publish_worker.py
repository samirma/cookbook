import os
import socket
import time
import subprocess
from zeroconf import ServiceInfo, Zeroconf

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

def get_ssh_port():
    # This is a bit of a hack, but it's the most reliable way to get the SSH port in Termux
    with os.popen("sshd -T | grep 'port' | awk '{print $2}' | head -n 1") as f:
        port = f.read().strip()
    return int(port) if port.isdigit() else 22

def get_username():
    """Executes the 'whoami' command to get the current username."""
    try:
        # Execute the command and decode the output, removing any trailing newline
        user_name = subprocess.check_output(['whoami']).decode('utf-8').strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Fallback if 'whoami' fails for some reason
        user_name = "unknown"
    return user_name

def main():
    user_name = get_username()
    port = get_ssh_port()
    ip_address = get_ip_address()
    hostname = socket.gethostname()

    zeroconf = Zeroconf()
    service_info = ServiceInfo(
        "_ssh._tcp.local.",
        f"Termux Worker {user_name}._ssh._tcp.local.",
        addresses=[socket.inet_aton(ip_address)],
        port=port,
        properties={'user': user_name, 'hostname': hostname},
        server=f"{hostname}.local.",
    )
    zeroconf.register_service(service_info)

    print(f"Publishing SSH service for user {user_name} on port {port}")
    print("Press Ctrl+C to stop.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        zeroconf.unregister_service(service_info)
        zeroconf.close()

if __name__ == "__main__":
    main()
