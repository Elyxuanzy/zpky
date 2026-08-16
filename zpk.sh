#!/bin/sh
set -eu

if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "WRONG: No internet"
    exit 1
fi

if ! command -v wget >/dev/null 2>&1; then
    echo "WRONG: wget is required"
    exit 1
fi

star_package(){
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  install  - install a package"
    echo "  version  - show version"
    echo "  list     - list installed packages"
    echo "  search   - search if package exists"
    echo "  reinstall- reinstall package"
    echo "  remove   - remove package"
    echo ""
}

if [ $# -eq 0 ]; then
    star_package
    exit 1
fi

NAME="zpky"
VERSION="1.0.0"
package_list=$(find . -name "list.ini" -type f)
package_store="$HOME/.$NAME"

if [ ! -d "$package_store" ]; then
    mkdir "$package_store"
    mkdir -p "$package_store/packages"
    mkdir -p "$package_store/bin"
fi

install_package_cn() {
    mirror_proxy="https://ghproxy.net/"

    if [ $# -lt 1 ]; then
        echo "E: Missing package name"
        echo "Usage: install <package>"
        exit 1
    fi

    if [ -z "$package_list" ]; then
        echo "E: Sorry, Unable to find list.ini"
        exit 1
    fi

    if [ -d "$package_store/packages/$1" ]; then
        echo "E: Package $1 is already installed"
        exit 1
    fi

    if grep -Fq "[$1]" "$package_list"; then
        url=$(grep -A1 "^\[$1\]$" "$package_list" | tail -n1)


        case "$url" in
            *github.com*)
                case "$url" in
                    ${mirror_proxy}*)
                        ;;
                    *)
                        url="${mirror_proxy}${url}"
                        ;;
                esac
                ;;
        esac

        case "$url" in
            *.tar.gz|*.tgz)
                wget -O "$package_store/packages/$1.tar.gz" "$url"
                mkdir -p "$package_store/packages/$1"
                tar -xzf "$package_store/packages/$1.tar.gz" -C "$package_store/packages/$1"
                rm "$package_store/packages/$1.tar.gz"

                for file in $(find "$package_store/packages/$1" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.ash" \)); do
                    chmod +x "$file"
                    ln -sf "$file" "$package_store/bin/$(basename "$file")"
                done

                for file in $(find "$package_store/packages/$1" -type f -exec grep -l "^#!/bin" {} \; 2>/dev/null); do
                    linkname="$package_store/bin/$(basename "$file")"
                    chmod +x "$file"
                    ln -sf "$file" "$linkname"
                done
                ;;
            *)

                wget -O "$package_store/bin/$1" "$url"
                chmod +x "$package_store/bin/$1"
                ;;
        esac

        echo "OK: Installed $1"
    else
        echo "E: Sorry, Unable to find package $1"
        exit 1
    fi
}

install_package() {
    if [ $# -lt 1 ]; then
        echo "E: Missing package name"
        echo "Usage: install <package>"
        exit 1
    fi

    if [ -z "$package_list" ]; then
        echo "E: Sorry, Unable to find list.ini"
        exit 1
    fi

    if [ -d "$package_store/packages/$1" ]; then
        echo "E: Package $1 is already installed"
        exit 1
    fi

    if grep -Fq "[$1]" "$package_list"; then
        url=$(grep -A1 "^\[$1\]$" "$package_list" | tail -n1)

        case "$url" in
            *.tar.gz|*.tgz)

                wget -O "$package_store/packages/$1.tar.gz" "$url"
                mkdir -p "$package_store/packages/$1"
                tar -xzf "$package_store/packages/$1.tar.gz" -C "$package_store/packages/$1"
                rm "$package_store/packages/$1.tar.gz"

                for file in $(find "$package_store/packages/$1" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.ash" \)); do
                    chmod +x "$file"
                    ln -sf "$file" "$package_store/bin/$(basename "$file")"
                done

                for file in $(find "$package_store/packages/$1" -type f -exec grep -l "^#!/bin" {} \; 2>/dev/null); do
                    linkname="$package_store/bin/$(basename "$file")"
                    chmod +x "$file"
                    ln -sf "$file" "$linkname"
                done
                ;;
            *)

                wget -O "$package_store/bin/$1" "$url"
                chmod +x "$package_store/bin/$1"
                ;;
        esac

        echo "OK: Installed $1"
    else
        echo "E: Sorry, Unable to find package $1"
        exit 1
    fi
}

remove_package() {
    if [ ! -d "$package_store/packages/$1" ]; then
        echo "E: Package $1 is not installed"
        exit 1
    fi

    rm -rf "$package_store/packages/$1"

    find "$package_store/bin" -type l 2>/dev/null | while read -r link; do
        target=$(readlink "$link")
        case "$target" in
            "$package_store/packages/$1"|"$package_store/packages/$1"/*)
                rm -f "$link"
                ;;
        esac
    done
    echo "OK: Uninstalled $1"
}

search_package(){
    if grep -Fq "[$1]" "$package_list"; then
        echo "[$1]"
    else
        exit 1
    fi
}

list_package(){
    ls "$package_store/bin"
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        --v|--version|version)
            echo "zpk version: $VERSION"
            exit 0
            ;;
        install)
            shift
            if [ $# -eq 0 ]; then
                echo "E: Missing package name"
                exit 1
            fi
            for pkg in "$@"; do
                install_package "$pkg"
            done
            exit 0
            ;;
        install-cn)
            shift
            if [ $# -eq 0 ]; then
                echo "E: Missing package name"
                exit 1
            fi
            for pkg in "$@"; do
                install_package_cn "$pkg"
            done
            exit 0
            ;;
        remove|uninstall)
            shift
            if [ $# -eq 0 ]; then
                echo "E: Missing package name"
                exit 1
            fi
            for pkg in "$@"; do
                remove_package "$pkg"
            done
            exit 0
            ;;
        reinstall)
            shift
            if [ $# -eq 0 ]; then
                echo "E: Missing package name"
                exit 1
            fi
            for pkg in "$@"; do
                if [ -d "$package_store/packages/$pkg" ]; then
                    remove_package "$pkg"
                fi
                install_package "$pkg"
            done
            exit 0
            ;;
        search)
            search_package "$2"
            exit 0
            ;;
        list)
            list_package
            exit 0
            ;;
        moo)
            echo "                 (__) "
            echo "                 (oo) "
            echo "           /------\/  "
            echo "          / |    ||   "
            echo "         *  /\---/\   "
            echo "            ~~   ~~   "
            echo "This $NAME has no Super Cow Powers"
            echo ""
            exit 0
            ;;
        help|--h|-h)
            star_package
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done