@SETLOCAL
@ECHO OFF
PUSHD %~dp0

docker run --rm -it -v %~dp0/.ssh:/root/.ssh dahenr/homelabbase /bin/bash