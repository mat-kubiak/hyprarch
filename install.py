import argparse

def message(mode: str, message: str):
    headers = {
        'info' : '\033[1;36m[INFO]\033[0m',
        'good' : '\033[1;32m[GOOD]\033[0m',
        'debug' : '\033[1;35m[DEBUG]\033[0m',
        'warn' : '\033[1;33m[WARNING]\033[0m',
        'error': '\033[1;31m[ERROR]\033[0m'
    }
    print(headers[mode] + ' ' + message)

def parse_cli():
    parser = argparse.ArgumentParser(
        prog='hyprarch',
        description='A complete Hyperland-based environment for Arch Linux.')
    parser.add_argument('-d', '--debug', action='store_true', help='Debug mode, won\'t install anything.',)
    parser.add_argument('-e', '--editor', default='nano', help='Specify the config editor. Either nano (default) or vim.')

    args = parser.parse_args()
    if args.editor != 'nano' and args.editor != 'vim':
        parser.error('-e/--editor argument can be either nano or vim!')
        exit
    return args

def main():
    args = parse_cli()
    message('good', 'Hello World!')

if __name__ == '__main__':
    main()
else:
    print('This isn\'t supposed to be a module!')
    exit
