from rich.console import Console
from rich.table import Table
import json
import os
import re
import subprocess
import sys

DEVICES = json.loads(os.environ.get('PCIDEVICES', ''))
console = Console()

def run(cmd):
    return subprocess.run(cmd, capture_output=True, shell=True)

def _getDeviceInfo(dev):
    did = dev['device']
    output = run(f"lspci -k -d {did}").stdout.decode()
    st_line = output.split('\n')[0]
    pci = st_line.split(' ')[0]
    match = re.search(r'Kernel driver in use:\s*(\S+)', output)
    driver = match.group(1) if match else 'none'
    mode = 'vfio' if driver == 'vfio-pci' else 'host'
    vendor, device = did.split(':')
    return {
        'name': dev['name'],
        'pci': pci,
        'vendor': vendor,
        'device': device,
        'mode': mode,
        'driver': driver,
        'def_driver': dev['driver']
    }

def getDevices():
    table = Table(title="PCI Devices", show_lines=False)
    table.add_column("PCI", style="cyan", no_wrap=True)
    table.add_column("ID", style="yellow")
    table.add_column("Name", style="magenta")
    table.add_column("Mode", style="green")
    for i in DEVICES:
        dev = _getDeviceInfo(i)
        mode_style = "bold green" if dev['mode'] == "vfio" else "bold red"
        table.add_row(
            dev['pci'],
            f"{dev['vendor']}:{dev['device']}",
            dev['name'],
            f"[{mode_style}]{dev['mode']}[/{mode_style}]"
        )
    console.print(table)

def switchKernel(dev):
    driver = "vfio-pci" if dev.get('mode') == 'host' else dev.get('def_driver')
    pci = f"0000:{dev.get('pci')}"
    ids = f"{dev['vendor']} {dev['device']}"
    unbind = run(f'echo {pci} | sudo tee /sys/bus/pci/devices/{pci}/driver/unbind')
    register = run(f'echo {ids} | sudo tee /sys/bus/pci/drivers/{driver}/new_id')
    bind = run(f'echo {pci} | sudo tee /sys/bus/pci/drivers/{driver}/bind')
    console.print(f"{dev['name']} changed to [bold]{'[green]vfio[/green]' if dev.get('mode') == 'host' else '[red]host[/red]'}[/bold]")

if __name__ == '__main__':
    args = sys.argv[1:]
    usage = """[bold]Usage:[/bold]
    [cyan]--list[/cyan]     List PCI devices and their driver info
    [cyan]--switch[/cyan]   Switch kernel driver for all devices
    """
    if len(args) == 0:
        console.print(usage)
        sys.exit()
    if args[0] == "--list":
        getDevices()
    elif args[0] == "--switch":
        for i in DEVICES:
            dev = _getDeviceInfo(i)
            switchKernel(dev)
    else:
        console.print(usage)
        sys.exit(1)