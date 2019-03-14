#!/bin/sh

cat ./extensions | while read -r line
do
  code --install-extension "$line"
done
