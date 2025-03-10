
#!/usr/bin/env python
import sys
import os
import platform

print("Python Environment Setup")
print("Python executable:", sys.executable)
print("Python version:", sys.version)

print("Checking for NumPy...")
try:
    import numpy
    print("NumPy already installed:", numpy.__version__)
except ImportError:
    print("NumPy not found, installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "numpy"])
    print("NumPy installed successfully")

print("Checking for SciPy...")
try:
    import scipy
    print("SciPy already installed:", scipy.__version__)
except ImportError:
    print("SciPy not found, installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "scipy"])
    print("SciPy installed successfully")

print("Creating wrapper script...")
python_exe = sys.executable

if platform.system() == "Windows":
    with open("run_nist.bat", "w") as f:
        f.write("@echo off\n")
        f.write(f'"{python_exe}" nist_tests_wrapper.py %*')
    print("Created Windows wrapper: run_nist.bat")
else:
    with open("run_nist.sh", "w") as f:
        f.write("#!/bin/bash\n")
        f.write(f'"{python_exe}" nist_tests_wrapper.py "$@"')
    os.chmod("run_nist.sh", 0o755)
    print("Created Unix wrapper: run_nist.sh")

print("Setup completed successfully")