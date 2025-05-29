#!/bin/sh

lockbook sync
rm -rf parth.cafe
rm -rf content
mkdir content
lockbook export parth.cafe .
mv parth.cafe/* content
