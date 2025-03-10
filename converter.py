import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import numpy as np
import scipy.io
import os

class NISTFormatter:
    def __init__(self, root):
        self.root = root
        self.root.title("MATLAB Array to NIST Test Suite Formatter")
        self.root.geometry("700x500")
        self.root.resizable(True, True)
        
        self.array_data = None
        self.filename = None
        
        # Create main frame
        self.main_frame = tk.Frame(root, padx=20, pady=20)
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        
        # File selection section
        self.file_frame = tk.LabelFrame(self.main_frame, text="File Selection", padx=10, pady=10)
        self.file_frame.pack(fill=tk.X, pady=10)
        
        self.file_path_var = tk.StringVar()
        self.file_path_entry = tk.Entry(self.file_frame, textvariable=self.file_path_var, width=50)
        self.file_path_entry.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        
        self.browse_button = tk.Button(self.file_frame, text="Browse", command=self.browse_file)
        self.browse_button.pack(side=tk.RIGHT, padx=5)
        
        # Format options
        self.options_frame = tk.LabelFrame(self.main_frame, text="Format Options", padx=10, pady=10)
        self.options_frame.pack(fill=tk.X, pady=10)
        
        # Format selection
        self.format_frame = tk.Frame(self.options_frame)
        self.format_frame.pack(fill=tk.X, pady=5)
        
        tk.Label(self.format_frame, text="Output Format:").pack(side=tk.LEFT, padx=5)
        
        self.format_var = tk.StringVar(value="binary")
        self.format_combobox = ttk.Combobox(self.format_frame, textvariable=self.format_var, 
                                           values=["binary", "01-ascii", "no-whitespace"])
        self.format_combobox.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        
        # Traversal order
        self.traverse_frame = tk.Frame(self.options_frame)
        self.traverse_frame.pack(fill=tk.X, pady=5)
        
        tk.Label(self.traverse_frame, text="Traversal Order:").pack(side=tk.LEFT, padx=5)
        
        self.order_var = tk.StringVar(value="row-major")
        self.order_combobox = ttk.Combobox(self.traverse_frame, textvariable=self.order_var, 
                                          values=["row-major", "column-major"])
        self.order_combobox.pack(side=tk.LEFT, padx=5, fill=tk.X, expand=True)
        
        # Matrix subset options
        self.subset_frame = tk.Frame(self.options_frame)
        self.subset_frame.pack(fill=tk.X, pady=5)
        
        self.use_subset_var = tk.BooleanVar(value=False)
        self.subset_check = tk.Checkbutton(self.subset_frame, text="Extract Subset", 
                                          variable=self.use_subset_var)
        self.subset_check.pack(side=tk.LEFT, padx=5)
        
        tk.Label(self.subset_frame, text="Size:").pack(side=tk.LEFT, padx=5)
        
        self.subset_size_var = tk.StringVar(value="10000")
        self.subset_size_entry = tk.Entry(self.subset_frame, textvariable=self.subset_size_var, width=10)
        self.subset_size_entry.pack(side=tk.LEFT, padx=5)
        
        # Status display
        self.status_frame = tk.LabelFrame(self.main_frame, text="Status", padx=10, pady=10)
        self.status_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        self.status_text = tk.Text(self.status_frame, height=10, width=50)
        self.status_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        self.status_text.config(state=tk.DISABLED)
        
        # Action buttons
        self.button_frame = tk.Frame(self.main_frame)
        self.button_frame.pack(fill=tk.X, pady=10)
        
        self.process_button = tk.Button(self.button_frame, text="Process Array", command=self.process_array)
        self.process_button.pack(side=tk.LEFT, padx=5)
        
        self.save_button = tk.Button(self.button_frame, text="Save for NIST Tests", command=self.save_to_file)
        self.save_button.pack(side=tk.LEFT, padx=5)
        self.save_button.config(state=tk.DISABLED)
        
        self.clear_button = tk.Button(self.button_frame, text="Clear", command=self.clear_all)
        self.clear_button.pack(side=tk.RIGHT, padx=5)
        
        # Store formatted output
        self.formatted_output = None
    
    def update_status(self, message):
        """Update the status text widget with a message"""
        self.status_text.config(state=tk.NORMAL)
        self.status_text.insert(tk.END, message + "\n")
        self.status_text.see(tk.END)
        self.status_text.config(state=tk.DISABLED)
    
    def browse_file(self):
        """Open file dialog to select MATLAB .mat file"""
        filename = filedialog.askopenfilename(
            title="Select MATLAB Array File",
            filetypes=[("MATLAB files", "*.mat"), ("All files", "*.*")]
        )
        
        if filename:
            self.file_path_var.set(filename)
            self.filename = filename
            self.update_status(f"Selected file: {os.path.basename(filename)}")
    
    def traverse_matrix(self, matrix, order):
        """Traverse the matrix in specified order and return flattened array"""
        rows, cols = matrix.shape
        result = []
        
        if order == "row-major":
            # Row by row (left to right, top to bottom)
            result = matrix.flatten()
        
        elif order == "column-major":
            # Column by column (top to bottom, left to right)
            result = matrix.T.flatten()
        
        return np.array(result)
    
    def process_array(self):
        """Load the MATLAB array and process it"""
        if not self.filename:
            messagebox.showerror("Error", "Please select a MATLAB file first")
            return
            
        try:
            # Load MATLAB file
            mat_data = scipy.io.loadmat(self.filename)
            
            # Find the array in the loaded data
            array_found = False
            for key in mat_data.keys():
                # Skip metadata variables that start with '__'
                if not key.startswith('__'):
                    self.array_data = mat_data[key]
                    array_name = key
                    array_found = True
                    break
                    
            if not array_found:
                raise ValueError("No valid array found in the MATLAB file")
            
            # Display information about the array
            self.update_status(f"Found array '{array_name}' with shape: {self.array_data.shape}")
            
            # Use subset if selected
            if self.use_subset_var.get():
                try:
                    subset_size = int(self.subset_size_var.get())
                    if subset_size <= 0:
                        raise ValueError("Subset size must be positive")
                        
                    # Determine how many elements to take from the array
                    total_elements = self.array_data.size
                    if subset_size > total_elements:
                        self.update_status(f"Warning: Requested subset size ({subset_size}) larger than array size ({total_elements}). Using full array.")
                        subset_size = total_elements
                    
                    # Flatten array and take first 'subset_size' elements
                    self.update_status(f"Extracting subset of {subset_size} elements")
                    flattened = self.array_data.flatten()[:subset_size]
                    
                    # Reshape to square if possible, otherwise keep as 1D
                    sqrt_size = int(np.sqrt(subset_size))
                    if sqrt_size**2 == subset_size:
                        # Perfect square, reshape to 2D
                        processed_array = flattened.reshape(sqrt_size, sqrt_size)
                        self.update_status(f"Reshaped to {sqrt_size}x{sqrt_size} matrix")
                    else:
                        # Not a perfect square, keep as 1D
                        processed_array = flattened.reshape(1, -1)
                        self.update_status(f"Using 1D array of length {subset_size}")
                
                except ValueError as e:
                    messagebox.showerror("Error", f"Invalid subset size: {str(e)}")
                    return
            else:
                processed_array = self.array_data
            
            # Get array traversal order
            order = self.order_var.get()
            self.update_status(f"Using traversal order: {order}")
            
            # Traverse the matrix in the specified order
            flattened_array = self.traverse_matrix(processed_array, order)
            
            # Format output based on selection
            format_type = self.format_var.get()
            
            if format_type == "binary":
                # Simple binary string, all together
                self.formatted_output = ''.join(map(str, flattened_array.astype(int)))
                self.update_status(f"Generated binary string of length {len(self.formatted_output)}")
            
            elif format_type == "01-ascii":
                # Each bit as ASCII '0' or '1' character, one per line
                self.formatted_output = '\n'.join(map(str, flattened_array.astype(int)))
                self.update_status(f"Generated ASCII 0/1 sequence with {len(flattened_array)} lines")
            
            elif format_type == "no-whitespace":
                # Just the bits concatenated with no whitespace
                self.formatted_output = ''.join(map(str, flattened_array.astype(int)))
                self.update_status(f"Generated compact binary string of length {len(self.formatted_output)}")
            
            # Count zeros and ones for verification
            num_zeros = np.sum(flattened_array == 0)
            num_ones = np.sum(flattened_array == 1)
            self.update_status(f"Processed binary sequence has {num_zeros} zeros and {num_ones} ones")
            proportion = num_ones / len(flattened_array)
            self.update_status(f"Proportion of ones: {proportion:.6f}")
            
            # Enable save button
            self.save_button.config(state=tk.NORMAL)
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to process file: {str(e)}")
            self.update_status(f"Error: {str(e)}")
    
    def save_to_file(self):
        """Save the formatted output to a text file"""
        if not self.formatted_output:
            messagebox.showerror("Error", "No processed data to save")
            return
            
        # Open save file dialog
        save_filename = filedialog.asksaveasfilename(
            title="Save For NIST Tests",
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("Binary files", "*.bin"), ("All files", "*.*")]
        )
        
        if save_filename:
            try:
                with open(save_filename, 'w') as f:
                    f.write(self.formatted_output)
                self.update_status(f"Successfully saved to: {os.path.basename(save_filename)}")
                
                # Also create a data.txt file for NIST testing if in same directory
                dir_path = os.path.dirname(save_filename)
                nist_data_path = os.path.join(dir_path, "data.txt")
                
                with open(nist_data_path, 'w') as f_nist:
                    f_nist.write(self.formatted_output)
                
                self.update_status(f"NIST test data saved to: data.txt in same directory")
                self.update_status("\nTo run NIST tests:")
                self.update_status("1. Place 'data.txt' in the randomness_testsuite directory")
                self.update_status("2. Run 'python3 main.py' to start the test suite")
                
                messagebox.showinfo("Success", "Files saved successfully.\nThe data.txt file is ready for NIST tests.")
            except Exception as e:
                messagebox.showerror("Error", f"Failed to save file: {str(e)}")
                self.update_status(f"Error saving file: {str(e)}")
    
    def clear_all(self):
        """Clear all data and reset the form"""
        self.file_path_var.set("")
        self.filename = None
        self.array_data = None
        self.formatted_output = None
        
        # Reset status
        self.status_text.config(state=tk.NORMAL)
        self.status_text.delete(1.0, tk.END)
        self.status_text.config(state=tk.DISABLED)
        
        # Disable save button
        self.save_button.config(state=tk.DISABLED)
        
        self.update_status("All data cleared")


if __name__ == "__main__":
    root = tk.Tk()
    app = NISTFormatter(root)
    root.mainloop()