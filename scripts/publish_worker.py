import os
import socket
import time
import subprocess
from zeroconf import ServiceInfo, Zeroconf

def get_ip_address():
    """Gets the primary IP address of the device."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't even have to be a reachable address
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1' # Fallback to loopback address
    finally:
        s.close()
    return IP

def get_ssh_port():
    """Gets the SSH port from the sshd configuration."""
    with os.popen("sshd -T | grep 'port' | awk '{print $2}' | head -n 1") as f:
        port = f.read().strip()
    return int(port) if port.isdigit() else 22

def get_username():
    """Executes the 'whoami' command to get the current username."""
    try:
        user_name = subprocess.check_output(['whoami']).decode('utf-8').strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        user_name = "unknown"
    return user_name

def main():
    user_name = get_username()
    port = get_ssh_port()
    ip_address = get_ip_address()
    hostname = socket.gethostname()

    zeroconf = Zeroconf()

    # Use a hyphen in the service name instead of a space
    service_name = f"Termux-Worker-{user_name}._ssh._tcp.local."

    service_info = ServiceInfo(
        "_ssh._tcp.local.",
        service_name,
        addresses=[socket.inet_aton(ip_address)],
        port=port,
        properties={'user': user_name},
        server=f"{hostname}.local.",
    )

    zeroconf.register_service(service_info)

    print(f"Publishing SSH service '{service_name}' for {user_name}@{ip_address} on port {port}")
    print("Press Ctrl+C to stop.")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        print("Stopping service...")
        zeroconf.unregister_service(service_info)
        zeroconf.close()

if __name__ == "__main__":
    main()
