#!/usr/bin/env bash
# Dev env for Wolfgangs SAR
git clone --depth 1 -b V0.2.1 https://github.com/insarlab/MiaplPy.git
cd MiaplPy
python -m pip install .
cd ..
