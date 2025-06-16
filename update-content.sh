#!/bin/sh

pwd
lockbook sync
lockbook export parth.cafe .
rm -rf src
mv parth.cafe src
