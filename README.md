# NIST_Matlab
A Matlab Port of the NIST Randomness Tests

This work implements a Matlab GUI and Python wrapper for the Python NIST randomness tests by stevenang (Available: https://github.com/stevenang/randomness_testsuite/tree/master).

## Directory Setup

1: Clone this entire repository.

2: Copy all of the .py files in the root directory of https://github.com/stevenang/randomness_testsuite/tree/master to this cloned repository (the Python wrapper searches for them within your new directory)

## Python Setup

This is more straightforward if you setup the Python environment before opening Matlab

1: Install Python 3.11 from https://www.python.org/downloads/release/python-3119/ and add to path.

2: Install numpy and scipy (open your new Python install folder in terminal and run "pip install numpy scipy").

3: Open the newly created directory in Matlab.

4: Run "pyenv('Version', 'your Python directory')" in the Matlab terminal.

5: Run the script called "NIST_Tests_GUI2.m" and the app should pop up.

6: Click on the "Verify Setup" button to double check the setup.

7: If the setup fails, run the script "fixPythonDependencies.m" -- it will search for valid Python installations and help you to finish the setup (may require a Matlab restart).

## Usage

The app accepts multiple file types, but I recommend using a .txt file as the input. There is an included converter "converter.py" that converts from .mat files to .txt with various options.

1: Within the GUI, upload your data using the "Browse" button.

2: Setup the data segmentation as you wish. The GUI will display the lowest p-value for each test across all of the runs, but the terminal will output all of the test results if you need them. (Note: the total bit length option will attempt to import the selected number of bits from the input, but will import the exact number of bits in the input file if the selected number of bits is greater than the input file.)

3: Select the tests you wish to run and click the "Run Tests" button.

4: Scroll through the "Debug Output" to verify that the tests were all imported properly.

5: Save the values either by selecting "Save Results" or copying from the Matlab terminal.
