#!/usr/bin/env python3
"""
Complete wrapper for NIST randomness tests suite.
"""

import sys
import os
import io
from io import StringIO
import importlib.util
import numpy as np
import argparse

def import_module_from_file(file_path):
    """Import a module from file path"""
    try:
        # Basic file existence check
        if not os.path.exists(file_path):
            print(f"ERROR: File does not exist: {file_path}")
            print(f"Working directory: {os.getcwd()}")
            print(f"Files in directory: {[f for f in os.listdir('.') if f.endswith('.py')]}")
            return None
            
        # Get the module name from the file path
        module_name = os.path.splitext(os.path.basename(file_path))[0]
        
        # Add the current directory to sys.path if it's not already there
        current_dir = os.path.dirname(os.path.abspath(file_path))
        if current_dir not in sys.path:
            sys.path.insert(0, current_dir)
        
        # Force reload the module if it already exists
        if module_name in sys.modules:
            del sys.modules[module_name]
        
        # Import the module directly
        spec = importlib.util.spec_from_file_location(module_name, file_path)
        if spec is None:
            print(f"Could not create module spec for: {module_name} at {file_path}")
            return None
            
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        spec.loader.exec_module(module)
        
        print(f"Successfully imported module: {module_name} from {file_path}")
        return module
        
    except ImportError as ie:
        print(f"Import error for {file_path}: {ie}")
        print(f"This might indicate missing dependencies or Python version incompatibility")
        return None
    except SyntaxError as se:
        print(f"Syntax error in {file_path}: {se}")
        print(f"This might indicate Python 2 vs Python 3 compatibility issues")
        return None
    except Exception as e:
        print(f"Error importing {file_path}: {e}")
        print(f"Exception type: {type(e).__name__}")
        return None

def load_data(filename, bit_length, offset=0):
    """
    Load binary data from a file with optional offset
    
    Args:
        filename (str): Path to the input file
        bit_length (int): Number of bits to process 
        offset (int): Bit offset from the start of the file
    
    Returns:
        str: Binary string containing the data
    """
    try:
        with open(filename, 'r') as f:
            binary_data = f.read().replace('\n', '').replace('\r', '').replace(' ', '')
        
        # Convert to integers (0 and 1)
        bits = [int(bit) for bit in binary_data if bit in ['0', '1']]
        
        # Convert back to string 
        binary_string = ''.join(str(bit) for bit in bits)
        
        # Handle offset and trim to requested length
        total_length = len(binary_string)
        
        if offset >= total_length:
            print(f"Warning: Requested offset ({offset}) exceeds data length ({total_length})")
            offset = 0
        
        # Extract the segment with offset
        end_index = min(offset + bit_length, total_length)
        segment = binary_string[offset:end_index]
        
        print(f"Data segment: offset={offset}, length={len(segment)}, requested={bit_length}")
        
        return segment
    except Exception as e:
        print(f"Error loading data: {e}")
        return ""

def run_selected_tests(input_file, bit_length, selected_tests, offset=0):
    """
    Run selected NIST randomness tests on the input data.
    
    Args:
        input_file (str): Path to the input file
        bit_length (int): Number of bits to process
        selected_tests (list): List of test names to run
        offset (int): Bit offset from the start of the file
    
    Returns:
        str: Results of the tests
    """
    # Capture stdout to get test results
    original_stdout = sys.stdout
    sys.stdout = string_buffer = StringIO()
    
    try:
        # Directory where this script is located (should also contain the test modules)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Print diagnostic information
        print(f"Python version: {sys.version}")
        print(f"Script directory: {script_dir}")
        print(f"Testing file: {input_file}")
        print(f"Bit length: {bit_length}")
        print(f"Offset: {offset}")
        print(f"Selected tests: {selected_tests}")
        print(f"Files in directory: {[f for f in os.listdir('.') if f.endswith('.py')]}")
        print("-" * 80)
        
        # Load the data with offset
        binary_data = load_data(input_file, bit_length, offset)
        
        # Check if we have enough data
        if len(binary_data) < bit_length:
            print(f"Warning: Input file contains only {len(binary_data)} bits, but {bit_length} were requested.")
            bit_length = len(binary_data)
        
        print(f"Loaded {len(binary_data)} bits from {input_file} (offset: {offset})")
        
        # Test module file mapping - verified with the GUI list
        test_file_map = {
            "frequency": "FrequencyTest.py",
            "block_frequency": "FrequencyTest.py",
            "runs": "RunTest.py",
            "longest_run": "RunTest.py",
            "rank": "Matrix.py",
            "fft": "Spectral.py",
            "non_overlapping_template": "TemplateMatching.py",
            "overlapping_template": "TemplateMatching.py",
            "universal": "Universal.py",
            "linear_complexity": "Complexity.py",
            "serial": "Serial.py",
            "approximate_entropy": "ApproximateEntropy.py",
            "cumulative_sums": "CumulativeSum.py",
            "random_excursions": "RandomExcursions.py",
            "random_excursions_variant": "RandomExcursions.py"
        }
        
        # Function name mapping - verified with the GUI list
        test_function_map = {
            "frequency": "FrequencyTest.monobit_test",
            "block_frequency": "FrequencyTest.block_frequency",
            "runs": "RunTest.run_test",
            "longest_run": "RunTest.longest_one_block_test",
            "rank": "Matrix.binary_matrix_rank_text",
            "fft": "SpectralTest.spectral_test",
            "non_overlapping_template": "TemplateMatching.non_overlapping_test",
            "overlapping_template": "TemplateMatching.overlapping_patterns",
            "universal": "Universal.statistical_test",
            "linear_complexity": "ComplexityTest.linear_complexity_test",
            "serial": "Serial.serial_test",
            "approximate_entropy": "ApproximateEntropy.approximate_entropy_test",
            "cumulative_sums": "CumulativeSums.cumulative_sums_test",
            "random_excursions": "RandomExcursions.random_excursions_test",
            "random_excursions_variant": "RandomExcursions.variant_test"
        }
        
        # Store test results with their p-values
        test_results = {}
        
        # Run each selected test
        for test_name in selected_tests:
            if test_name in test_file_map:
                try:
                    print(f"\nRunning {test_name} test...")
                    module_path = os.path.join(script_dir, test_file_map[test_name])
                    
                    # Check if the file exists
                    if not os.path.isfile(module_path):
                        print(f"Error: Test module file {module_path} not found.")
                        continue
                    
                    # Import the module directly
                    module = import_module_from_file(module_path)
                    if module is None:
                        print(f"Error: Failed to import module from {module_path}.")
                        continue
                    
                    # Get the test function using the correct format
                    function_name = test_function_map[test_name]
                    
                    # Check if the function is a class method
                    if '.' in function_name:
                        # Handle class method format like "FrequencyTest.monobit_test"
                        class_name, method_name = function_name.split('.')
                        if hasattr(module, class_name) and hasattr(getattr(module, class_name), method_name):
                            test_class = getattr(module, class_name)
                            test_func = getattr(test_class, method_name)
                        else:
                            print(f"Error: Class {class_name} or method {method_name} not found in module {test_name}.")
                            print(f"Available classes: {[c for c in dir(module) if not c.startswith('_') and c[0].isupper()]}")
                            if hasattr(module, class_name):
                                print(f"Available methods in {class_name}: {[m for m in dir(getattr(module, class_name)) if not m.startswith('_')]}")
                            continue
                    else:
                        # Direct function call
                        if not hasattr(module, function_name):
                            print(f"Error: Function {function_name} not found in module {test_name}.")
                            # List available functions in the module
                            print(f"Available functions: {[f for f in dir(module) if not f.startswith('_')]}")
                            continue
                        
                        test_func = getattr(module, function_name)
                    
                    # Call the appropriate test function with default parameters
                    if test_name == "block_frequency":
                        p_value = test_func(binary_data, 128, True)  # Block size parameter
                    elif test_name == "non_overlapping_template":
                        p_value = test_func(binary_data, True)  # Using default template pattern
                    elif test_name == "overlapping_template":
                        p_value = test_func(binary_data, True)  # Using default pattern size
                    elif test_name == "serial" or test_name == "approximate_entropy":
                        p_value = test_func(binary_data, True)  # Using default pattern length
                    elif test_name == "random_excursions_variant":
                        p_value = test_func(binary_data, True)  # Using default parameters
                    else:
                        p_value = test_func(binary_data, True)  # verbose=True for all tests
                    
                    # Store the result and handle various return types
                    test_results[test_name] = p_value
                    
                    # Check if p_value is a valid numerical value
                    try:
                        # Handle tuple returns (some tests might return multiple p-values)
                        if isinstance(p_value, tuple):
                            # Use the first p-value if it's a tuple
                            p_value_numeric = float(p_value[0])
                        else:
                            # Try to convert to float (works for int, float, numpy types)
                            p_value_numeric = float(p_value)
                            
                        # Format the result output
                        result_status = "PASS" if p_value_numeric > 0.01 else "FAIL"
                        print(f"{test_name} test result: {p_value_numeric:.6f} ({result_status})")
                    except (TypeError, ValueError):
                        # If p_value can't be converted to a number, report it as-is
                        print(f"{test_name} test result: {p_value} (UNKNOWN)")
                        test_results[test_name] = "ERROR"
                    
                except Exception as e:
                    print(f"Error running {test_name} test: {e}")
                    import traceback
                    traceback.print_exc()
            else:
                print(f"Unknown test: {test_name}")
        
        # Add summary of results
        print("\n" + "=" * 40)
        print("SUMMARY OF RESULTS")
        print("=" * 40)
        
        # Count passes more safely
        pass_count = 0
        error_count = 0
        for test_name, result in test_results.items():
            try:
                # Handle tuple returns
                if isinstance(result, tuple):
                    result_val = float(result[0])
                elif result == "ERROR":
                    error_count += 1
                    continue
                else:
                    result_val = float(result)
                    
                if result_val > 0.01:
                    pass_count += 1
            except (TypeError, ValueError):
                # If a result can't be converted to float, don't count it
                error_count += 1
                
        total_count = len(test_results)
        
        if total_count > 0:
            pass_rate = (pass_count / total_count) * 100
            print(f"Tests run: {total_count}")
            print(f"Tests passed: {pass_count} ({pass_rate:.1f}%)")
            print(f"Tests failed: {total_count - pass_count - error_count} ({(100 - pass_rate - (error_count/total_count*100)):.1f}%)")
            if error_count > 0:
                print(f"Tests with errors: {error_count} ({(error_count/total_count*100):.1f}%)")
        else:
            print("No tests were successfully completed.")
        
        # Return the captured output
        return string_buffer.getvalue()
    
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc(file=string_buffer)
        return string_buffer.getvalue()
    
    finally:
        # Restore stdout
        sys.stdout = original_stdout

# This allows running directly from command line for testing
def scan_test_files():
    """Scan the current directory for test files and try to identify function names and classes"""
    print("Scanning for NIST test files...")
    test_files = [f for f in os.listdir('.') if f.endswith('.py') and 'Test' in f]
    print(f"Found {len(test_files)} potential test files: {test_files}")
    
    for file in test_files:
        print(f"\nExamining {file}:")
        try:
            # Try to import the module directly
            module = import_module_from_file(file)
            if module is None:
                print(f"  Error: Could not import {file}")
                continue
                
            # Look for classes
            classes = [c for c in dir(module) if not c.startswith('_') and c[0].isupper()]
            print(f"  Classes found: {classes}")
            
            # For each class, look for methods
            for class_name in classes:
                class_obj = getattr(module, class_name)
                methods = [m for m in dir(class_obj) if not m.startswith('_') and callable(getattr(class_obj, m))]
                print(f"  Methods in {class_name}: {methods}")
            
            # Look for direct functions
            functions = [f for f in dir(module) if not f.startswith('_') and callable(getattr(module, f)) and not f[0].isupper()]
            if functions:
                print(f"  Direct functions: {functions}")
                
        except Exception as e:
            print(f"  Error analyzing file: {e}")

if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='NIST Randomness Test Suite Wrapper')
    parser.add_argument('input_file', help='Path to the input binary file')
    parser.add_argument('bit_length', type=int, help='Number of bits to process')
    parser.add_argument('tests', nargs='?', default='all', help='Comma-separated list of tests to run')
    parser.add_argument('--offset', type=int, default=0, help='Bit offset from start of file')
    parser.add_argument('--scan', action='store_true', help='Scan for test files and exit')
    
    args = parser.parse_args()
    
    # Special command to scan test files
    if args.scan:
        scan_test_files()
        sys.exit(0)
    
    # Parse tests
    if args.tests == 'all':
        selected_tests = ["frequency", "block_frequency", "runs", "longest_run",
                         "rank", "fft", "non_overlapping_template",
                         "overlapping_template", "universal", "linear_complexity",
                         "serial", "approximate_entropy", "cumulative_sums",
                         "random_excursions", "random_excursions_variant"]
    else:
        selected_tests = args.tests.split(',')
    
    # Run tests
    results = run_selected_tests(args.input_file, args.bit_length, selected_tests, args.offset)
    print(results)
