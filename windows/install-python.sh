#!/bin/bash
set -exo pipefail

export WINEARCH=win64
export WINEDEBUG=fixme-all
export WINEPREFIX=/wine

PYTHON_TARGET_DIR="Python"
PYTHON_WIN_DIR="C:\\${PYTHON_TARGET_DIR}"
winetricks win10
for msifile in "core" "dev" "exe" "lib" "path" "pip" "tcltk" "tools"; do
    wget -nv "https://www.python.org/ftp/python/$PYTHON_VERSION/amd64/${msifile}.msi"
    wine msiexec /i "${msifile}.msi" /qb TARGETDIR="$PYTHON_WIN_DIR"
    rm ${msifile}.msi
done

cd "/wine/drive_c/$PYTHON_TARGET_DIR"

mkdir -p /usr/local/bin-wine
echo "wine '${PYTHON_WIN_DIR}\python.exe' \$@" > /usr/local/bin-wine/python
echo "wine '${PYTHON_WIN_DIR}\Scripts\easy_install.exe \$@" > /usr/local/bin-wine/easy_install
echo "wine '${PYTHON_WIN_DIR}\Scripts\pip.exe' \$@" > /usr/local/bin-wine/pip
echo "wine '${PYTHON_WIN_DIR}\Scripts\pyinstaller.exe' \$@" > /usr/local/bin-wine/pyinstaller
echo "wine '${PYTHON_WIN_DIR}\Scripts\pyupdater.exe' \$@" > /usr/local/bin-wine/pyupdater
chmod +x /usr/local/bin-wine/*
echo 'assoc .py=PythonScript' | wine cmd
echo "ftype PythonScript=${PYTHON_WIN_DIR}\python.exe \"%1\" %\*" | wine cmd
while pgrep wineserver >/dev/null; do
  echo "Waiting for wineserver" >&2
  sleep 1
done

# Make it easy on users, grab our common package mangers
PATH="/usr/local/bin-wine:$PATH"
pip install pipenv
echo "wine '${PYTHON_WIN_DIR}\Scripts\pipenv.exe' \$@" > /usr/local/bin-wine/pipenv

pip install poetry
echo "wine '${PYTHON_WIN_DIR}\Scripts\poetry.exe' \$@" > /usr/local/bin-wine/poetry

chmod +x /usr/local/bin-wine/*
rm -rf /tmp/.wine-*
