from rich.console import Console
from rich.table import Table
import json
import os
import re
import subprocess
import sys
import termios
import tty
import time

console = Console()

def run(cmd):
    return subprocess.run(cmd, capture_output=True, shell=True)

def getProcNames(fuser_output_str):
    process_names = []
    lines = fuser_output_str.strip().split('\n')

    if not lines:
        return process_names

    for line in lines[1:]:
        parts = line.split()
        if parts:
            process_names.append(f" - {parts[-1][1:]}")
            
    return process_names

def read_key():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch

def _getDeviceInfo():
    devices = []
    for dev in json.loads(os.environ.get('PCIDEVICES', '')):
        did = dev['device']
        output = run(f"lspci -k -d {did}").stdout.decode()
        st_line = output.split('\n')[0]
        pci = st_line.split(' ')[0]
        match = re.search(r'Kernel driver in use:\s*(\S+)', output)
        driver = match.group(1) if match else 'none'
        mode = 'vfio' if driver == 'vfio-pci' else 'host'
        vendor, device = did.split(':')
        devices.append({
            'name': dev['name'],
            'pci': pci,
            'vendor': vendor,
            'device': device,
            'mode': mode,
            'driver': driver,
            'def_driver': dev['driver']
            })
    return devices

def getDevices(devices):
    table = Table(title="PCI Devices", show_lines=False)
    table.add_column("PCI", style="cyan", no_wrap=True)
    table.add_column("ID", style="yellow")
    table.add_column("Name", style="magenta")
    table.add_column("Mode", style="green")
    for dev in devices:
        mode_style = "bold green" if dev['mode'] == "vfio" else "bold red"
        table.add_row(
            dev['pci'],
            f"{dev['vendor']}:{dev['device']}",
            dev['name'],
            f"[{mode_style}]{dev['mode']}[/{mode_style}]"
        )
    console.print(table)

def gpuDettach(dev):
    pci_address = f"{dev['pci']}"
    gpu_index = None

    try:
        smi_output = run("nvidia-smi -L").stdout.decode()
        for line in smi_output.strip().split('\n'):
            match_index = re.match(r"GPU (\d+):", line)
            if match_index:
                current_gpu_index = match_index.group(1)
                pci_query_cmd = f"nvidia-smi --query-gpu=pci.bus_id --format=csv,noheader -i {current_gpu_index}"
                pci_bus_id_output = run(pci_query_cmd).stdout.decode().strip()
                if pci_address in pci_bus_id_output:
                    gpu_index = current_gpu_index
                    break

    except Exception as e:
        console.print(f"[red]Error getting GPU index from nvidia-smi: {e}[/red]")
        return

    if gpu_index is not None:
        # run(f"sudo nvidia-smi -pm 0 -i {gpu_index}")

        fuser_v_result = run(f"fuser -v /dev/nvidia{gpu_index}")
        pids = fuser_v_result.stdout.decode().strip()
        proc_names = getProcNames(fuser_v_result.stderr.decode().strip())

        if fuser_v_result.returncode == 0 and pids:
            console.print('Note: Switching to vfio will kill the following processes:')
            if proc_names:
                console.print(f"[bold]{'\n'.join(proc_names)}[/bold]")
            else:
                console.print(pids)
            console.print('Are you sure you want to continue? (y/n): ', end='')
            while True:
                u = read_key()
                if u.lower() == 'y':
                    console.print('')
                    break
                elif u.lower() == 'n':
                    console.print('\nExiting. No changes made.')
                    sys.exit()

            kill_cmd = f"sudo fuser -k /dev/nvidia{gpu_index}"
            kill_result = run(kill_cmd)
            time.sleep(0.5)

            if not kill_result.stderr:
                console.print(f"[yellow]No processes found or killed by fuser on /dev/nvidia{gpu_index} (or fuser not effective).[/yellow]")

        reset_cmd = f"sudo nvidia-smi --gpu-reset -i {gpu_index}"
        reset_result = run(reset_cmd)
        if reset_result.returncode != 0:
           console.print(f"[yellow]GPU {gpu_index} reset failed or not supported. Output: {reset_result.stdout.decode()} {reset_result.stderr.decode()}[/yellow]")

def getSoundDevice(dev):
    lspci_output = run(f"lspci -nn | grep -A3 {dev['pci'][:-1]}1").stdout.decode().strip()
    if len(lspci_output) > 0:
        try:
            pci = re.search(r'(\w+:\w+\.\w+)', lspci_output).group(1)
            vendor, device = re.search(r'\[(\w+:\w+)\]', lspci_output[0]).group(1).split(':')
            kernel = re.search(r'Kernel modules:\s*(\S+)', lspci_output).group(1).split(': ')[1]
        except:
            return None
        return {'name': 'GPU Audio', 'pci': pci, 'vendor': vendor, 'device': device, 'def_kernel': kernel}

def gpuAttach(dev):
    run(f"sudo nvidia-smi -pm 1 -i 0000:{dev['pci']}")

def switchKernel(dev): # not working fix sometime else
    devs = [dev]
    is_nvidia = True if dev['vendor'] == '10de' else False
    if is_nvidia and dev['mode'] == 'host':
        sound_dev = getSoundDevice(dev)
        devs.append(sound_dev)
        gpuDettach(dev)

    for sdev in devs:
        driver_switch = "vfio-pci" if sdev['mode'] == 'host' else sdev['def_driver']
        pci = f"0000:{sdev['pci']}"
        ids = f"{sdev['vendor']} {sdev['device']}"    
        unbind = run(f'echo {pci} | sudo tee /sys/bus/pci/devices/{pci}/driver/unbind')
        register = run(f'echo {ids} | sudo tee /sys/bus/pci/drivers/{driver_switch}/new_id')
        bind = run(f'echo {pci} | sudo tee /sys/bus/pci/drivers/{driver_switch}/bind')
        console.print(f"{sdev['name']} changed to [bold]{'[green]vfio[/green]' if sdev['mode'] == 'host' else '[red]host[/red]'}[/bold]")

    # if is_nvidia and dev['mode'] == 'vfio':
    #     gpuAttach(dev)


if __name__ == '__main__':
    args = sys.argv[1:]
    usage = """[bold]Usage:[/bold]
    [cyan]--list[/cyan]     List PCI devices and their driver info
    [cyan]--switch[/cyan]   Switch kernel driver for all devices
    """

    if len(args) == 0:
        console.print(usage)
        sys.exit(1)

    devices = _getDeviceInfo()
    if args[0] == "--list":
        getDevices(devices)
    elif args[0] == "--switch":
        getDevices(devices)
        user_input = input("Choose a device (id) to switch: ")
        for dev in devices:
            if dev['device'] in user_input:
                switchKernel(dev)
