#! /usr/bin/env sh

flutter --version | grep Flutter | awk '{ print $2 }' > flutter_version
