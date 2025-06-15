#!/bin/sh

lockbook sync
rm -rf src
lockbook export parth.cafe .
mv parth.cafe src
