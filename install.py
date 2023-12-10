import argparse
import requests
import platform
import os

class paths:
    installer_dir = os.path.dirname(os.path.realpath(__file__))
    config_dir = os.path.join(installer_dir, 'config')
    wallpaper_dir = os.path.join(installer_dir, 'wallpapers')
    temp_dir = os.path.join(installer_dir, 'temp')

    config_file = os.path.join(config_dir, 'config.ini')
    log_file = os.path.join(config_dir, 'log')

def message(mode: str, mes: str):
    headers = {
        'info' : '\033[1;36m[INFO]\033[0m',
        'success' : '\033[1;32m[SUCCESS]\033[0m',
        'debug' : '\033[1;35m[DEBUG]\033[0m',
        'warning' : '\033[1;33m[WARNING]\033[0m',
        'error': '\033[1;31m[ERROR]\033[0m'
    }
    print(headers[mode] + ' ' + mes)

def has_internet_access():
    try:
        response = requests.get("https://google.com", timeout=5)
        return True
    except requests.ConnectionError:
        return False

def parse_cli():
    parser = argparse.ArgumentParser(
        prog='hyprarch',
        description='A complete Hyperland-based environment for Arch Linux.')
    parser.add_argument('-d', '--debug', action='store_true', help='Debug mode, won\'t install anything.',)
    parser.add_argument('-e', '--editor', default='nano', help='Specify the config editor. Either nano (default) or vim.')

    args = parser.parse_args()
    if args.editor != 'nano' and args.editor != 'vim':
        parser.error('-e/--editor argument can be either nano or vim!')
        exit(1)
    return args

def main():
    args = parse_cli()
    
    # PLATFORM CHECK
    if platform.system() != 'Linux':
        message('error', 'This script will only work for Linux! Detected os: ' + platform.system())
        exit(1)
    
    # DISTRO CHECK
    distro = platform.freedesktop_os_release()["ID"]
    if distro != 'arch':
        message('error', 'This script will only work for Arch! Detected distribution: ' + distro)
        exit(1)

    # INTERNET CHECK
    message('info', 'Checking internet connection...')
    if not has_internet_access():
        message('error', 'Internet not connected!')
        exit(1)
    message('success', 'Internet connected!')

    # WELCOME
    print('')
    message('info', 'Hello! This script will install the whole Hyprland ecosystem along with software specified in config.ini.')
    message('info', 'If something goes wrong, look for the log file in the script\'s directory.')
    message('warning', 'If you aren\'t sure what software the script will install and whether you want it, please consult with the README')
    if input("Do you want to continue? (y/n) ") != 'y':
        exit()

    message('info', 'rest of the program')

if __name__ == '__main__':
    main()
else:
    print('This isn\'t supposed to be a module!')