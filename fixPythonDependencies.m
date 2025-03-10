function fixPythonMismatch
    % This function helps identify and fix Python installation mismatches
    % between MATLAB and your system
    
    disp('==== Python Installation Mismatch Detector ====');
    
    % Step 1: Find which Python MATLAB is using
    try
        py_ver = pyversion;
        matlab_python = char(py_ver.Executable);
        disp(['MATLAB is using Python from: ' matlab_python]);
        disp(['Python version: ' char(py_ver)]);
    catch e
        disp('No Python configured in MATLAB');
        disp(['Error: ' getReport(e)]);
        matlab_python = '';
    end
    
    % Step 2: Find which Python the system uses by default
    if ispc % Windows
        [status, cmdout] = system('where python');
        if status == 0
            system_pythons = strsplit(strtrim(cmdout), newline);
            disp('System Python installations:');
            for i = 1:length(system_pythons)
                disp(['  ' num2str(i) ': ' system_pythons{i}]);
            end
            system_python = system_pythons{1}; % Default is the first one
        else
            disp('Could not find Python in system PATH');
            system_python = '';
        end
    else % macOS/Linux
        [status, cmdout] = system('which python');
        if status == 0
            system_python = strtrim(cmdout);
            disp(['System is using Python from: ' system_python]);
        else
            [status, cmdout] = system('which python3');
            if status == 0
                system_python = strtrim(cmdout);
                disp(['System is using Python from: ' system_python]);
            else
                disp('Could not find Python in system PATH');
                system_python = '';
            end
        end
    end
    
    % Step 3: Find all Python installations that have NumPy
    disp(' ');
    disp('Searching for Python installations with NumPy...');
    
    % Find potential Python installations
    potential_pythons = findAllPythonInstallations();
    
    % Check each one for NumPy
    valid_pythons = {};
    for i = 1:length(potential_pythons)
        py_path = potential_pythons{i};
        has_numpy = checkForNumpy(py_path);
        
        if has_numpy
            valid_pythons{end+1} = py_path;
            disp(['  ✓ ' py_path ' - Has NumPy installed']);
        else
            disp(['  ✗ ' py_path ' - NumPy NOT found']);
        end
    end
    
    % Step 4: Determine what action to take
    disp(' ');
    if ~isempty(valid_pythons)
        disp('Found Python installations with NumPy. Would you like to:');
        disp('  1. Switch MATLAB to use one of these Python installations');
        disp('  2. Install NumPy in the Python that MATLAB is currently using');
        disp('  3. Exit without making changes');
        
        choice = input('Enter your choice (1, 2, or 3): ');
        
        switch choice
            case 1
                selectPythonForMatlab(valid_pythons);
            case 2
                installNumPyForMatlab(matlab_python);
            otherwise
                disp('No changes made.');
        end
    else
        disp('No Python installations with NumPy were found.');
        disp('Would you like to:');
        disp('  1. Install NumPy in the Python that MATLAB is currently using');
        disp('  2. Exit without making changes');
        
        choice = input('Enter your choice (1 or 2): ');
        
        if choice == 1
            installNumPyForMatlab(matlab_python);
        else
            disp('No changes made.');
        end
    end
end

function pythons = findAllPythonInstallations()
    % Find all Python installations on the system
    pythons = {};
    
    if ispc % Windows
        % Common Python installation paths on Windows
        possible_paths = {
            'C:\Python*\python.exe', 
            'C:\Program Files\Python*\python.exe',
            'C:\Users\*\AppData\Local\Programs\Python\Python*\python.exe',
            'C:\ProgramData\Anaconda*\python.exe',
            'C:\Users\*\Anaconda*\python.exe',
            'C:\Users\*\miniconda*\python.exe'
        };
        
        for i = 1:length(possible_paths)
            matches = dir(possible_paths{i});
            for j = 1:length(matches)
                if ~matches(j).isdir
                    pythons{end+1} = fullfile(matches(j).folder, matches(j).name);
                end
            end
        end
        
        % Check PATH
        [status, cmdout] = system('where python');
        if status == 0
            paths = strsplit(strtrim(cmdout), newline);
            for i = 1:length(paths)
                if ~isempty(paths{i}) && ~ismember(paths{i}, pythons)
                    pythons{end+1} = paths{i};
                end
            end
        end
        
    else % macOS/Linux
        % Common Python installation paths on Unix systems
        possible_paths = {
            '/usr/bin/python*',
            '/usr/local/bin/python*',
            '~/anaconda*/bin/python*',
            '~/miniconda*/bin/python*',
            '/opt/anaconda*/bin/python*',
            '/opt/python*/bin/python*'
        };
        
        for i = 1:length(possible_paths)
            matches = dir(possible_paths{i});
            for j = 1:length(matches)
                if ~matches(j).isdir
                    pythons{end+1} = fullfile(matches(j).folder, matches(j).name);
                end
            end
        end
        
        % Check PATH
        [status, cmdout] = system('which -a python python3');
        if status == 0
            paths = strsplit(strtrim(cmdout), newline);
            for i = 1:length(paths)
                if ~isempty(paths{i}) && ~ismember(paths{i}, pythons)
                    pythons{end+1} = paths{i};
                end
            end
        end
    end
    
    % Remove duplicates
    pythons = unique(pythons);
end

function has_numpy = checkForNumpy(python_path)
    % Check if a given Python installation has NumPy
    
    try
        % Build command to check for NumPy
        cmd = ['"' python_path '" -c "import scipy; print(''NumPy found'')" 2>nul'];
        
        % Execute the command
        [status, cmdout] = system(cmd);
        
        % Check result
        has_numpy = (status == 0) && contains(cmdout, 'NumPy found');
    catch
        has_numpy = false;
    end
end

function selectPythonForMatlab(valid_pythons)
    % Let the user select which Python to use with MATLAB
    
    disp('Select a Python installation to use with MATLAB:');
    for i = 1:length(valid_pythons)
        disp(['  ' num2str(i) ': ' valid_pythons{i}]);
    end
    
    idx = input(['Enter the number (1-' num2str(length(valid_pythons)) '): ']);
    
    if idx >= 1 && idx <= length(valid_pythons)
        selected_python = valid_pythons{idx};
        
        % Configure MATLAB to use this Python
        try
            disp(['Setting MATLAB to use Python from: ' selected_python]);
            pyenv('Version', selected_python);
            new_py = pyversion;
            disp(['Successfully configured Python: ' char(new_py)]);
            disp('You must restart MATLAB for this change to take full effect.');
            
            % Test if NumPy is available now
            try
                py.importlib.invalidate_caches();
                py.importlib.import_module('numpy');
                disp('NumPy is now available! (But a restart is still recommended)');
            catch e
                disp(['Error importing NumPy: ' getReport(e)]);
                disp('Please restart MATLAB for the changes to take effect.');
            end
            
        catch e
            disp(['Error configuring Python: ' getReport(e)]);
        end
    else
        disp('Invalid selection. No changes made.');
    end
end

function installNumPyForMatlab(matlab_python)
    % Install NumPy in the Python that MATLAB is using
    
    if isempty(matlab_python)
        disp('No Python configured in MATLAB.');
        return;
    end
    
    disp(['Attempting to install NumPy for Python at: ' matlab_python]);
    
    % Get pip path based on Python path
    [folder, ~] = fileparts(matlab_python);
    
    if ispc % Windows
        pip_cmd = fullfile(folder, 'Scripts', 'pip.exe');
        if ~exist(pip_cmd, 'file')
            pip_cmd = fullfile(folder, 'pip.exe');
        end
    else % macOS/Linux
        pip_cmd = fullfile(folder, 'pip');
        if ~exist(pip_cmd, 'file')
            pip_cmd = fullfile(folder, 'pip3');
        end
    end
    
    if ~exist(pip_cmd, 'file')
        % If pip not found in expected location, try using it through Python
        pip_cmd = ['"' matlab_python '" -m pip'];
    else
        pip_cmd = ['"' pip_cmd '"'];
    end
    
    % Install NumPy and SciPy
    try
        disp('Installing NumPy...');
        cmd = [pip_cmd ' install numpy'];
        disp(['Executing: ' cmd]);
        [status, cmdout] = system(cmd);
        
        if status == 0
            disp('NumPy installation successful!');
        else
            disp(['NumPy installation failed: ' cmdout]);
        end
        
        disp('Installing SciPy...');
        cmd = [pip_cmd ' install scipy'];
        disp(['Executing: ' cmd]);
        [status, cmdout] = system(cmd);
        
        if status == 0
            disp('SciPy installation successful!');
        else
            disp(['SciPy installation failed: ' cmdout]);
        end
        
        disp('You must restart MATLAB for these installations to take effect.');
        
    catch e
        disp(['Error during package installation: ' getReport(e)]);
    end
end