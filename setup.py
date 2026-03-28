#!/usr/bin/env python3
"""
Installer script for orpheusmorebetter.
"""

from setuptools import setup, find_packages

import re

VERSIONFILE = "_version.py"
verstrline = open(VERSIONFILE, "rt").read()
VSRE = r"^__version__ = ['\"]([^'\"]*)['\"]"
mo = re.search(VSRE, verstrline, re.M)
if mo:
    verstr = mo.group(1)
else:
    raise RuntimeError("Unable to find version string in %s." % (VERSIONFILE,))

setup(
    name="orpheusmorebetter",
    description="Automatically transcode and upload FLACs on orpheus.network.",
    version=verstr,
    url="https://github.com/CHODEUS/orpheusmorebetter",
    packages=["models", "services"],
    scripts=["orpheusmorebetter"],
    install_requires=[
        "beautifulsoup4>=4.13.4,<5.0.0",
        "mutagen>=1.47.0,<2.0.0",
        "requests>=2.32.4,<3.0.0",
        "lxml>=5.4.0,<6.0.0",
        "pydantic>=2.11.5,<3.0.0",
    ],
)
