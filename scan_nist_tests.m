function Debug_NIST_Tests_GUI
    % Debug version of the NIST Tests GUI with more detailed error reporting
    
    % Create the main figure window
    fig = figure('Name', 'NIST Randomness Test Suite (Debug)', ...
                'Position', [100, 100, 900, 700], ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'NumberTitle', 'off');
    
    % Data panel
    dataPanel = uipanel(fig, 'Title', 'Input Data', ...
                      'Position', [0.05, 0.75, 0.9, 0.2]);
    
    % Input controls
    uicontrol(dataPanel, 'Style', 'text', ...
             'String', 'Input File:', ...
             'Position', [20, 80, 100, 20]);
    
    inputFileEdit = uicontrol(dataPanel, 'Style', 'edit', ...
                            'Position', [130, 80, 400, 25], ...
                            'HorizontalAlignment', 'left');
    
    uicontrol(dataPanel, 'Style', 'pushbutton', ...
             'String', 'Browse', ...
             'Position', [540, 80, 100, 25], ...
             'Callback', {@browseFile, inputFileEdit});
    
    uicontrol(dataPanel, 'Style', 'text', ...
             'String', 'Bit Length:', ...
             'Position', [20, 40, 100, 20]);
    
    bitLengthEdit = uicontrol(dataPanel, 'Style', 'edit', ...
                            'String', '1000', ...
                            'Position', [130, 40, 100, 25]);
    
    % Debug panel - new section for debug info
    debugPanel = uipanel(fig, 'Title', 'Debug Information', ...
                       'Position', [0.05, 0.55, 0.9, 0.15]);
                   
    debugText = uicontrol(debugPanel, 'Style', 'edit', ...
                         'Max', 2, ... % Make it multiline
                         'HorizontalAlignment', 'left', ...
                         'Position', [20, 10, 820, 80], ...
                         'Enable', 'inactive');
    
    % Tests panel
    testsPanel = uipanel(fig, 'Title', 'Available Tests', ...
                       'Position', [0.05, 0.35, 0.4, 0.15]);
    
    % Test checkboxes (simplified for debugging - just include frequency tests)
    tests = {'Frequency', 'Block Frequency'};
    
    testValues = {'frequency', 'block_frequency'};
    
    checkboxes = cell(length(tests), 1);
    for i = 1:length(tests)
        checkboxes{i} = uicontrol(testsPanel, 'Style', 'checkbox', ...
                                'String', tests{i}, ...
                                'Tag', testValues{i}, ...
                                'Value', 1, ...
                                'Position', [20+180*(i-1), 30, 150, 20]);
    end
    
    % Parameters panel
    paramsPanel = uipanel(fig, 'Title', 'Test Parameters & Tools', ...
                        'Position', [0.5, 0.35, 0.45, 0.15]);
    
    % Add a Python path field
    uicontrol(paramsPanel, 'Style', 'text', ...
             'String', 'Python Path (optional):', ...
             'Position', [20, 30, 150, 20]);
    
    pythonPathEdit = uicontrol(paramsPanel, 'Style', 'edit', ...
                             'Position', [180, 30, 200, 25], ...
                             'HorizontalAlignment', 'left', ...
                             'Tooltip', 'Leave empty to use default Python');
    
    % Output panel
    outputPanel = uipanel(fig, 'Title', 'Results', ...
                        'Position', [0.05, 0.05, 0.9, 0.25]);
    
    % Results text area with scroll capability
    resultsText = uicontrol(outputPanel, 'Style', 'edit', ...
                          'Max', 2, ... % Make it multiline
                          'HorizontalAlignment', 'left', ...
                          'Position', [20, 20, 820, 100], ...
                          'Enable', 'inactive');
    
    % Run test button
    uicontrol(fig, 'Style', 'pushbutton', ...
             'String', 'Run Tests', ...
             'Position', [280, 270, 100, 30], ...
             'Callback', {@runTests, inputFileEdit, bitLengthEdit, checkboxes, resultsText, debugText, pythonPathEdit});
    
    % Add a direct debug button
    uicontrol(fig, 'Style', 'pushbutton', ...
             'String', 'Run Debug Command', ...
             'Position', [400, 270, 150, 30], ...
             'Callback', {@runDebugCommand, debugText, resultsText});
    
    % Get list of files
    files = dir('*.py');
    fileList = {};
    for i = 1:length(files)
        fileList{end+1} = files(i).name;
    end
    
    % Display list of files in debug text
    set(debugText, 'String', ['Python files in directory: ' strjoin(fileList, ', ')]);
end

function browseFile(~, ~, fileEdit)
    % Open file browser dialog
    [filename, pathname] = uigetfile({'*.txt;*.bin;*.dat', 'Data Files (*.txt, *.bin, *.dat)'; ...
                                     '*.*', 'All Files (*.*)'}, ...
                                     'Select Input File');
    if filename ~= 0
        set(fileEdit, 'String', fullfile(pathname, filename));
    end
end

function runTests(~, ~, inputFileEdit, bitLengthEdit, checkboxes, resultsText, debugText, pythonPathEdit)
    % Run NIST tests using the Python wrapper with extra debug info
    inputFile = get(inputFileEdit, 'String');
    bitLength = str2double(get(bitLengthEdit, 'String'));
    pythonPath = get(pythonPathEdit, 'String');
    
    if isempty(inputFile)
        set(resultsText, 'String', 'Error: Please select an input file.');
        return;
    end
    
    if isnan(bitLength) || bitLength <= 0
        set(resultsText, 'String', 'Error: Invalid bit length.');
        return;
    end
    
    % Configure Python if path is provided
    if ~isempty(pythonPath)
        try
            pyenv('Version', pythonPath);
            set(debugText, 'String', ['Configured Python: ' char(pyversion)]);
        catch e
            set(resultsText, 'String', ['Error configuring Python: ' getReport(e)]);
            return;
        end
    end
    
    % Get Python version info
    try
        ver = char(pyversion);
        set(debugText, 'String', ['Using Python: ' ver]);
    catch e
        set(debugText, 'String', ['Error getting Python version: ' getReport(e)]);
    end
    
    % Determine which tests to run
    selectedTests = {};
    for i = 1:length(checkboxes)
        if get(checkboxes{i}, 'Value') == 1
            selectedTests{end+1} = get(checkboxes{i}, 'Tag');
        end
    end
    
    if isempty(selectedTests)
        set(resultsText, 'String', 'Error: Please select at least one test.');
        return;
    end
    
    % Show what we're about to do
    debugMsg = sprintf('About to run tests: %s\nInput file: %s\nBit length: %d', ...
                       strjoin(selectedTests, ', '), inputFile, bitLength);
    set(debugText, 'String', debugMsg);
    
    % Run the selected tests
    set(resultsText, 'String', 'Running tests... Please wait.');
    drawnow;
    
    try
        % Method 1: Direct system call with verbose output
        cmd = '';
        if ispc
            cmd = 'python nist_tests_wrapper.py';
        else
            cmd = 'python3 nist_tests_wrapper.py';
        end
        
        tempFile = [tempname, '.txt'];
        testsStr = strjoin(selectedTests, ',');
        
        fullCmd = sprintf('%s "%s" %d "%s" > "%s" 2>&1', ...
                         cmd, inputFile, bitLength, testsStr, tempFile);
        
        set(debugText, 'String', ['Executing: ' fullCmd]);
        drawnow;
        
        [status, cmdout] = system(fullCmd);
        
        if exist(tempFile, 'file')
            % Read the results
            fileID = fopen(tempFile, 'r');
            results = fscanf(fileID, '%c');
            fclose(fileID);
            delete(tempFile);
            
            % Display results
            set(resultsText, 'String', results);
            
            % Update debug with status
            set(debugText, 'String', sprintf('Command execution status: %d\n%s', status, debugMsg));
        else
            set(resultsText, 'String', ['Error: No output file created. Command output: ' cmdout]);
        end
        
    catch e
        set(resultsText, 'String', ['Error: ' getReport(e)]);
        set(debugText, 'String', ['Exception details: ' getReport(e, 'extended')]);
    end
end

function runDebugCommand(~, ~, debugText, resultsText)
    % Function to run an arbitrary debug command
    
    % Some useful debug commands
    debugCommands = {'dir *.py', ...
                    'python -c "import sys; print(sys.path)"', ...
                    'python simple_nist_wrapper.py --scan', ...
                    'python -c "import os; print(os.listdir(''.''))"'};
    
    % Let user select a command
    [selected, ok] = listdlg('ListString', debugCommands, ...
                           'SelectionMode', 'single', ...
                           'Name', 'Debug Command', ...
                           'PromptString', 'Select a debug command:');
    
    if ~ok
        return;
    end
    
    % Execute the selected command
    cmd = debugCommands{selected};
    set(debugText, 'String', ['Executing: ' cmd]);
    drawnow;
    
    try
        [status, cmdout] = system(cmd);
        set(resultsText, 'String', sprintf('Command: %s\nStatus: %d\nOutput:\n%s', ...
                                         cmd, status, cmdout));
    catch e
        set(resultsText, 'String', ['Error executing command: ' getReport(e)]);
    end
end