import subprocess
import os

def ping(host):
    result = subprocess.run(
        'ping -c2 %s &> /dev/null' % host,
        shell=True
    )
    if result.returncode == 0:
        print('%s:up' % host)
    else:
        print('%s:down' % host)

if __name__ == '__main__':
    ips = ('172.40.58.%s' % i for i in range(1, 255))
    for ip in ips:
        retval = os.fork()
        if not retval:
            ping(ip)
            exit()
