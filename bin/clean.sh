#!/bin/bash

find . -name "Move.lock" -exec rm -rf {} \;
find . -type d -name build -exec rm -rf {} \;
