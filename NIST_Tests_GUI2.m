function NIST_Tests_GUI
    
    % Define colors
    bgColor = [0.15, 0.15, 0.3]; % Dark blue background
    panelColor = [0.2, 0.2, 0.35]; % Slightly lighter for panels
    textColor = [0.9, 0.9, 0.9]; % Light text color
    
    % Create the main figure window with fixed size - larger to fit all tests
    fig = figure('Name', 'NIST Randomness Test Suite', ...
                'Position', [100, 100, 1000, 800], ... % Larger window
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'NumberTitle', 'off', ...
                'Resize', 'off', ... % Fixed window size
                'Color', bgColor);
    
    % Data panel
    dataPanel = uipanel(fig, 'Title', 'Input Data', ...
                      'Position', [0.05, 0.85, 0.9, 0.12], ...
                      'BackgroundColor', panelColor, ...
                      'ForegroundColor', textColor, ...
                      'HighlightColor', textColor, ...
                      'ShadowColor', bgColor);
    
    % Input controls
    uicontrol(dataPanel, 'Style', 'text', ...
             'String', 'Input File:', ...
             'Position', [20, 60, 100, 20], ...
             'BackgroundColor', panelColor, ...
             'ForegroundColor', textColor, ...
             'HorizontalAlignment', 'left');
    
    inputFileEdit = uicontrol(dataPanel, 'Style', 'edit', ...
                            'Position', [130, 60, 450, 25], ...
                            'HorizontalAlignment', 'left', ...
                            'BackgroundColor', [0.25, 0.25, 0.4], ...
                            'ForegroundColor', textColor);
    
    uicontrol(dataPanel, 'Style', 'pushbutton', ...
             'String', 'Browse', ...
             'Position', [590, 60, 100, 25], ...
             'Callback', {@browseFile, inputFileEdit}, ...
             'BackgroundColor', [0.3, 0.3, 0.45], ...
             'ForegroundColor', textColor);
    
    uicontrol(dataPanel, 'Style', 'text', ...
             'String', 'Total Bit Length:', ...
             'Position', [20, 25, 100, 20], ...
             'BackgroundColor', panelColor, ...
             'ForegroundColor', textColor, ...
             'HorizontalAlignment', 'left');
    
    bitLengthEdit = uicontrol(dataPanel, 'Style', 'edit', ...
                            'String', '1000000', ...
                            'Position', [130, 25, 100, 25], ...
                            'BackgroundColor', [0.25, 0.25, 0.4], ...
                            'ForegroundColor', textColor);
    
    % Add segmented test option
    uicontrol(dataPanel, 'Style', 'text', ...
             'String', 'Bits Per Test:', ...
             'Position', [250, 25, 100, 20], ...
             'BackgroundColor', panelColor, ...
             'ForegroundColor', textColor, ...
             'HorizontalAlignment', 'left');
    
    bitsPerTestEdit = uicontrol(dataPanel, 'Style', 'edit', ...
                              'String', '100000', ...
                              'Position', [350, 25, 100, 25], ...
                              'BackgroundColor', [0.25, 0.25, 0.4], ...
                              'ForegroundColor', textColor);
    
    % Number of test runs
    uicontrol(dataPanel, 'Style', 'text', ...
             'String', 'Number of Runs:', ...
             'Position', [470, 25, 100, 20], ...
             'BackgroundColor', panelColor, ...
             'ForegroundColor', textColor, ...
             'HorizontalAlignment', 'left');
    
    numRunsEdit = uicontrol(dataPanel, 'Style', 'edit', ...
                         'String', '1', ...
                         'Position', [570, 25, 50, 25], ...
                         'BackgroundColor', [0.25, 0.25, 0.4], ...
                         'ForegroundColor', textColor);
    
    % Tests panel (taller to fit all tests without scrolling)
    testsPanel = uipanel(fig, 'Title', 'Available Tests', ...
                       'Position', [0.05, 0.25, 0.9, 0.55], ... % Taller panel
                       'BackgroundColor', panelColor, ...
                       'ForegroundColor', textColor, ...
                       'HighlightColor', textColor, ...
                       'ShadowColor', bgColor);
    
    % Test checkboxes
    tests = {'Frequency (Monobit)', 'Block Frequency', 'Runs', 'Longest Run of Ones', ...
             'Binary Matrix Rank', 'Discrete Fourier Transform', 'Non-Overlapping Template', ...
             'Overlapping Template', 'Universal Statistical', 'Linear Complexity', ...
             'Serial', 'Approximate Entropy', 'Cumulative Sums', ...
             'Random Excursions', 'Random Excursions Variant'};
    
    testValues = {'frequency', 'block_frequency', 'runs', 'longest_run', ...
                 'rank', 'fft', 'non_overlapping_template', ...
                 'overlapping_template', 'universal', 'linear_complexity', ...
                 'serial', 'approximate_entropy', 'cumulative_sums', ...
                 'random_excursions', 'random_excursions_variant'};
    
    % Initialize cell arrays for UI controls
    checkboxes = cell(length(tests), 1);
    resultLabels = cell(length(tests), 1);
    pValueLabels = cell(length(tests), 1);
    
    % Calculate position for each test (evenly distributed in the panel)
    panelHeight = 0.55 * 800; % Convert position to pixels
    rowHeight = 25;
    numRows = length(tests);
    
    % Set up the test list with result boxes
    for i = 1:length(tests)
        y_pos = panelHeight - (i+1) * rowHeight;
        
        % Test checkbox
        checkboxes{i} = uicontrol(testsPanel, 'Style', 'checkbox', ...
                                'String', tests{i}, ...
                                'Tag', testValues{i}, ...
                                'Value', 1, ...
                                'Position', [20, y_pos, 300, 20], ...
                                'BackgroundColor', panelColor, ...
                                'ForegroundColor', textColor);
        
        % P-value display
        uicontrol(testsPanel, 'Style', 'text', ...
                'String', 'P-value:', ...
                'Position', [340, y_pos, 60, 20], ...
                'BackgroundColor', panelColor, ...
                'ForegroundColor', textColor, ...
                'HorizontalAlignment', 'right');
        
        pValueLabels{i} = uicontrol(testsPanel, 'Style', 'text', ...
                            'String', '-', ...
                            'Tag', [testValues{i}, '_pvalue'], ...
                            'Position', [410, y_pos, 100, 20], ...
                            'BackgroundColor', [0.25, 0.25, 0.4], ...
                            'ForegroundColor', textColor, ...
                            'HorizontalAlignment', 'center');
        
        % Result display (Pass/Fail)
        resultLabels{i} = uicontrol(testsPanel, 'Style', 'text', ...
                            'String', '-', ...
                            'Tag', [testValues{i}, '_result'], ...
                            'Position', [520, y_pos, 100, 20], ...
                            'BackgroundColor', [0.25, 0.25, 0.4], ...
                            'ForegroundColor', textColor, ...
                            'HorizontalAlignment', 'center');
    end
    
    % Select All / Deselect All buttons
    uicontrol(testsPanel, 'Style', 'pushbutton', ...
             'String', 'Select All', ...
             'Position', [650, 360, 100, 25], ...
             'Callback', {@selectAll, checkboxes, 1}, ...
             'BackgroundColor', [0.3, 0.3, 0.45], ...
             'ForegroundColor', textColor);
    
    uicontrol(testsPanel, 'Style', 'pushbutton', ...
             'String', 'Deselect All', ...
             'Position', [650, 320, 100, 25], ...
             'Callback', {@selectAll, checkboxes, 0}, ...
             'BackgroundColor', [0.3, 0.3, 0.45], ...
             'ForegroundColor', textColor);
    
    % Reset Results button
    uicontrol(testsPanel, 'Style', 'pushbutton', ...
             'String', 'Reset Results', ...
             'Position', [650, 280, 100, 25], ...
             'Callback', {@resetResults, pValueLabels, resultLabels}, ...
             'BackgroundColor', [0.3, 0.3, 0.45], ...
             'ForegroundColor', textColor);
    
    % Parameters panel
    paramsPanel = uipanel(fig, 'Title', 'Python Setup', ...
                        'Position', [0.05, 0.15, 0.45, 0.08], ...
                        'BackgroundColor', panelColor, ...
                        'ForegroundColor', textColor, ...
                        'HighlightColor', textColor, ...
                        'ShadowColor', bgColor);
    
    % Add a Python path field
    uicontrol(paramsPanel, 'Style', 'text', ...
             'String', 'Python Path (optional):', ...
             'Position', [10, 30, 150, 20], ...
             'BackgroundColor', panelColor, ...
             'ForegroundColor', textColor, ...
             'HorizontalAlignment', 'left');
    
    pythonPathEdit = uicontrol(paramsPanel, 'Style', 'edit', ...
                             'Position', [160, 30, 220, 25], ...
                             'HorizontalAlignment', 'left', ...
                             'Tooltip', 'Leave empty to use default Python', ...
                             'BackgroundColor', [0.25, 0.25, 0.4], ...
                             'ForegroundColor', textColor);
    
    % Add a verify button
    verifyBtn = uicontrol(paramsPanel, 'Style', 'pushbutton', ...
                        'String', 'Verify Setup', ...
                        'Position', [290, 5, 100, 25], ...
                        'Callback', {@verifySetup, pythonPathEdit}, ...
                        'BackgroundColor', [0.3, 0.3, 0.45], ...
                        'ForegroundColor', textColor);
    
    % Control panel
    controlPanel = uipanel(fig, 'Title', 'Controls', ...
                        'Position', [0.55, 0.15, 0.4, 0.08], ...
                        'BackgroundColor', panelColor, ...
                        'ForegroundColor', textColor, ...
                        'HighlightColor', textColor, ...
                        'ShadowColor', bgColor);
    
    % Run test button
    runBtn = uicontrol(controlPanel, 'Style', 'pushbutton', ...
                     'String', 'Run Tests', ...
                     'Position', [30, 20, 100, 30], ...
                     'Callback', {@runTests, inputFileEdit, bitLengthEdit, checkboxes, ...
                                 pythonPathEdit, bitsPerTestEdit, numRunsEdit, ...
                                 pValueLabels, resultLabels}, ...
                     'BackgroundColor', [0.3, 0.6, 0.3], ...
                     'ForegroundColor', textColor);
    
    % Add save results button
    saveBtn = uicontrol(controlPanel, 'Style', 'pushbutton', ...
                     'String', 'Save Results', ...
                     'Position', [150, 20, 100, 30], ...
                     'Callback', {@saveResults}, ...
                     'BackgroundColor', [0.3, 0.3, 0.6], ...
                     'ForegroundColor', textColor);
    
    % Output panel
    outputPanel = uipanel(fig, 'Title', 'Debug Output', ...
                        'Position', [0.05, 0.02, 0.9, 0.11], ...
                        'BackgroundColor', panelColor, ...
                        'ForegroundColor', textColor, ...
                        'HighlightColor', textColor, ...
                        'ShadowColor', bgColor);
    
    % Results text area with scroll capability
    resultsText = uicontrol(outputPanel, 'Style', 'edit', ...
                          'Max', 2, ... % Make it multiline
                          'HorizontalAlignment', 'left', ...
                          'Position', [10, 10, 880, 60], ...
                          'Enable', 'inactive', ...
                          'BackgroundColor', [0.15, 0.15, 0.25], ...
                          'ForegroundColor', textColor, ...
                          'FontName', 'Courier New', ... % Monospaced font for better formatting
                          'Tag', 'debugOutput');
                          
    % Store all UI elements in the figure's UserData for access in callbacks
    userData = struct();
    userData.checkboxes = checkboxes;
    userData.pValueLabels = pValueLabels;
    userData.resultLabels = resultLabels;
    userData.resultsText = resultsText;
    userData.lastResults = [];
    set(fig, 'UserData', userData);
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

function selectAll(~, ~, checkboxes, value)
    % Set all checkboxes to the specified value
    for i = 1:length(checkboxes)
        set(checkboxes{i}, 'Value', value);
    end
end

function resetResults(~, ~, pValueLabels, resultLabels)
    % Reset all test results
    for i = 1:length(pValueLabels)
        set(pValueLabels{i}, 'String', '-');
        set(pValueLabels{i}, 'BackgroundColor', [0.25, 0.25, 0.4]);
        set(resultLabels{i}, 'String', '-');
        set(resultLabels{i}, 'BackgroundColor', [0.25, 0.25, 0.4]);
    end
    
    % Clear debug output
    fig = gcf;
    userData = get(fig, 'UserData');
    set(userData.resultsText, 'String', '');
    userData.lastResults = [];
    set(fig, 'UserData', userData);
end

function verifySetup(~, ~, pythonPathEdit)
    % Verify Python and the test modules are set up correctly
    pythonPath = get(pythonPathEdit, 'String');
    
    % Get debug output field
    fig = gcf;
    userData = get(fig, 'UserData');
    resultsText = userData.resultsText;
    
    set(resultsText, 'String', 'Verifying Python setup... Please wait.');
    drawnow;
    
    try
        % Configure Python if path is provided
        if ~isempty(pythonPath)
            pyenv('Version', pythonPath);
        end
        
        % Display Python version
        ver = pyversion;
        verOutput = ['Python version: ' char(ver)];
        set(resultsText, 'String', verOutput);
        
        % Check if the wrapper script exists
        if ~exist('nist_tests_wrapper2.py', 'file')
            error('nist_tests_wrapper2.py not found in the current directory.');
        end
        
        % Try to import the wrapper module
        try
            py.importlib.import_module('nist_tests_wrapper2');
            msgbox('Setup verification successful. Python and wrapper script found.', 'Verification Success', 'help');
            set(resultsText, 'String', [verOutput newline 'Wrapper script found and validated.']);
        catch e
            % Try to diagnose the issue
            msg = ['Error importing wrapper module: ' char(e.message) ...
                  newline newline 'Please check that nist_tests_wrapper2.py is in the current directory and is valid Python code.'];
            errordlg(msg, 'Import Error');
            set(resultsText, 'String', [verOutput newline 'ERROR: ' msg]);
        end
        
    catch e
        errordlg(['Error verifying setup: ' getReport(e)], 'Verification Error');
        set(resultsText, 'String', ['ERROR: ' getReport(e)]);
    end
end

function runTests(~, ~, inputFileEdit, bitLengthEdit, checkboxes, pythonPathEdit, bitsPerTestEdit, numRunsEdit, pValueLabels, resultLabels)
    % Run NIST tests using the Python wrapper
    inputFile = get(inputFileEdit, 'String');
    totalBitLength = str2double(get(bitLengthEdit, 'String'));
    bitsPerTest = str2double(get(bitsPerTestEdit, 'String'));
    numRuns = str2double(get(numRunsEdit, 'String'));
    pythonPath = get(pythonPathEdit, 'String');
    
    % Get debug output field
    fig = gcf;
    userData = get(fig, 'UserData');
    resultsText = userData.resultsText;
    
    % Reset results
    resetResults([], [], pValueLabels, resultLabels);
    
    if isempty(inputFile)
        set(resultsText, 'String', 'Error: Please select an input file.');
        return;
    end
    
    if isnan(totalBitLength) || totalBitLength <= 0
        set(resultsText, 'String', 'Error: Invalid total bit length.');
        return;
    end
    
    if isnan(bitsPerTest) || bitsPerTest <= 0
        set(resultsText, 'String', 'Error: Invalid bits per test.');
        return;
    end
    
    if isnan(numRuns) || numRuns <= 0
        set(resultsText, 'String', 'Error: Invalid number of runs.');
        return;
    end
    
    % Configure Python if path is provided
    if ~isempty(pythonPath)
        try
            pyenv('Version', pythonPath);
        catch e
            set(resultsText, 'String', ['Error configuring Python: ' getReport(e)]);
            return;
        end
    end
    
    % Determine which tests to run
    selectedTests = {};
    selectedIndices = [];
    for i = 1:length(checkboxes)
        if get(checkboxes{i}, 'Value') == 1
            selectedTests{end+1} = get(checkboxes{i}, 'Tag');
            selectedIndices(end+1) = i;
        end
    end
    
    if isempty(selectedTests)
        set(resultsText, 'String', 'Error: Please select at least one test.');
        return;
    end
    
    % Calculate actual number of bits to use
    actualBits = min(totalBitLength, bitsPerTest);
    
    % Set up results storage
    allResults = {};
    totalResCount = 0;
    passCount = 0;
    
    % Run the selected tests multiple times if requested
    for run = 1:numRuns
        % Update status
        statusMsg = sprintf('Running test set %d of %d... Please wait.', run, numRuns);
        set(resultsText, 'String', statusMsg);
        drawnow;
        
        try
            % Method 1: Try using the Python interface
            try
                % Calculate offset for this run
                if numRuns > 1 && totalBitLength > bitsPerTest
                    % Divide the data into segments if possible
                    maxOffset = totalBitLength - bitsPerTest;
                    % Distribute offsets evenly across the data
                    offset = floor((run-1) * (maxOffset / (numRuns-1)));
                    if run == numRuns
                        offset = maxOffset; % Ensure the last run uses the last segment
                    end
                else
                    offset = 0;
                end
                
                % Call the Python wrapper with offset and length
                results = callNistTestsPy(inputFile, actualBits, selectedTests, offset);
            catch pyError
                % Method 2: Fall back to direct system call if Python interface fails
                disp(['Python interface error: ' getReport(pyError)]);
                disp('Falling back to direct system call...');
                results = callNistTestsDirect(inputFile, actualBits, selectedTests, offset);
            end
            
            % Store results
            allResults{run} = results;
            
            % Parse results to extract p-values and pass/fail status
            if run == numRuns
                [pValues, passStatus] = parsePValues(results, selectedTests);
                
                % Update UI with results
                for i = 1:length(selectedIndices)
                    idx = selectedIndices(i);
                    testName = selectedTests{i};
                    
                    if isfield(pValues, testName)
                        % Update p-value
                        if ~isnan(pValues.(testName))
                            % Special handling for universal test with -1
                            if strcmp(testName, 'universal') && pValues.(testName) == -1
                                set(pValueLabels{idx}, 'String', '-1');
                            else
                                % Format regular p-values
                                set(pValueLabels{idx}, 'String', sprintf('%.4f', pValues.(testName)));
                            end
                            
                            % Update pass/fail status with color coding
                            if passStatus.(testName)
                                set(resultLabels{idx}, 'String', 'PASS');
                                set(resultLabels{idx}, 'BackgroundColor', [0.2, 0.7, 0.2]);
                                set(pValueLabels{idx}, 'BackgroundColor', [0.2, 0.7, 0.2]);
                                passCount = passCount + 1;
                            else
                                if strcmp(testName, 'universal') && pValues.(testName) == -1
                                    set(resultLabels{idx}, 'String', 'INVALID');
                                    set(resultLabels{idx}, 'BackgroundColor', [0.9290, 0.6940, 0.1250]);
                                else
                                    set(resultLabels{idx}, 'String', 'FAIL');
                                    set(resultLabels{idx}, 'BackgroundColor', [0.7, 0.2, 0.2]);
                                    set(pValueLabels{idx}, 'BackgroundColor', [0.7, 0.2, 0.2]);
                                end
                            end
                            
                            totalResCount = totalResCount + 1;
                        else
                            % Handle error case
                            set(pValueLabels{idx}, 'String', 'ERROR');
                            set(resultLabels{idx}, 'String', '-');
                            set(pValueLabels{idx}, 'BackgroundColor', [0.7, 0.5, 0.0]);
                        end
                    end
                end
            end
            
        catch e
            set(resultsText, 'String', ['Error: ' getReport(e)]);
            return;
        end
    end
    
    % Combine all results for display
    combinedResults = '';
    for i = 1:length(allResults)
        if numRuns > 1
            combinedResults = [combinedResults '--- Run ' num2str(i) ' of ' num2str(numRuns) ' ---' newline];
        end
        combinedResults = [combinedResults allResults{i} newline];
    end
    
    % Add summary if tests were completed
    if totalResCount > 0
        summaryLine = sprintf('Summary: %d/%d tests passed (%.1f%%)', passCount, totalResCount, (passCount/totalResCount*100));
        combinedResults = [combinedResults newline '=== ' summaryLine ' ==='];
    end
    
    % Display results
    set(resultsText, 'String', combinedResults);
    
    % Store results in figure user data for later saving
    userData.lastResults = combinedResults;
    set(fig, 'UserData', userData);
end

function [pValues, passStatus] = parsePValues(resultsText, selectedTests)
    % Parse the output text to extract p-values and determine pass/fail status
    pValues = struct();
    passStatus = struct();
    
    % Initialize with default values
    for i = 1:length(selectedTests)
        pValues.(selectedTests{i}) = NaN;
        passStatus.(selectedTests{i}) = false;
    end
    
    % Define the tests that return multiple p-values
    multiValueTests = {'block_frequency', 'serial', 'random_excursions', 'random_excursions_variant'};
    
    % Split the results by line
    lines = strsplit(resultsText, '\n');
    
    % Look specifically for the clear pattern "test result:" for all tests
    for i = 1:length(selectedTests)
        testName = selectedTests{i};
        isMultiValue = ismember(testName, multiValueTests);
        
        % Print debug info
        fprintf('Processing %s (multi-value: %d)\n', testName, isMultiValue);
        
        % First look for the specific "test result:" pattern
        resultValues = [];
        
        for j = 1:length(lines)
            line = lines{j};
            pattern = [testName ' test result:'];
            
            if contains(line, pattern)
                % Found a line with test results
                fprintf('  Found result line: %s\n', line);
                
                % Extract p-value(s)
                parts = strsplit(line, ':');
                if length(parts) > 1
                    valueStr = strtrim(parts{2});
                    fprintf('  Raw value string: "%s"\n', valueStr);
                    
                    % Extract numeric values
                    [numbers, ~] = extractNumbersFromString(valueStr);
                    
                    % Filter for valid p-values (between 0 and 1)
                    % Special handling for universal test - sometimes outputs values > 1 or -1
                    if strcmp(testName, 'universal')
                        % For the universal test, accept all values including negative ones
                        validValues = numbers;
                        
                        % If there are -1 values, those indicate failure
                        if any(validValues == -1)
                            % Keep the -1 value to indicate failure
                            validValues = [-1];
                        elseif ~isempty(numbers(numbers >= 0 & numbers <= 1))
                            % If there are values between 0-1, prefer those
                            validValues = numbers(numbers >= 0 & numbers <= 1);
                        end
                    else
                        % For other tests, only accept values between 0-1
                        validValues = numbers(numbers >= 0 & numbers <= 1);
                    end
                    
                    if ~isempty(validValues)
                        resultValues = [resultValues, validValues];
                        fprintf('  Found valid p-values: %s\n', mat2str(validValues));
                    end
                end
            end
        end
        
        % If we didn't find any specific test result lines, search more broadly
        if isempty(resultValues)
            fprintf('  No specific result line found, searching for any p-values\n');
            
            for j = 1:length(lines)
                line = lines{j};
                
                if contains(line, testName) && ~contains(line, 'test result:')
                    % Special handling for universal test
                    if strcmp(testName, 'universal') && contains(lower(line), 'p-value')
                        fprintf('  Found universal test p-value line: %s\n', line);
                        
                        % Try to extract p-value following "p-value" text
                        pValueIndex = strfind(lower(line), 'p-value');
                        if ~isempty(pValueIndex)
                            restOfLine = line(pValueIndex(1)+7:end);
                            [numbers, ~] = extractNumbersFromString(restOfLine);
                            if ~isempty(numbers)
                                resultValues = [resultValues, numbers];
                                fprintf('  Extracted universal p-value: %s\n', mat2str(numbers));
                            end
                        end
                    else
                        % Standard extraction for other tests
                        [numbers, ~] = extractNumbersFromString(line);
                        
                        % Apply appropriate filtering based on test type
                        if strcmp(testName, 'universal')
                            validValues = numbers;
                            if any(validValues == -1)
                                validValues = [-1];
                            elseif ~isempty(numbers(numbers >= 0 & numbers <= 1))
                                validValues = numbers(numbers >= 0 & numbers <= 1);
                            end
                        else
                            validValues = numbers(numbers >= 0 & numbers <= 1);
                        end
                        
                        if ~isempty(validValues)
                            resultValues = [resultValues, validValues];
                            fprintf('  Found potential p-values: %s\n', mat2str(validValues));
                        end
                    end
                end
            end
        end
        
        % Process the collected p-values
        if ~isempty(resultValues)
            if isMultiValue && length(resultValues) > 1
                % For multi-value tests with multiple results, use lowest
                minValue = min(resultValues);
                pValues.(testName) = minValue;
                passStatus.(testName) = minValue > 0.01;
                fprintf('  Using minimum p-value for %s: %f\n', testName, minValue);
            else
                % For single-value tests or multi-value tests with only one result
                % For universal test, handle -1 specially
                if strcmp(testName, 'universal') && any(resultValues == -1)
                    pValues.(testName) = -1;
                    passStatus.(testName) = false; % -1 always means FAIL for universal test
                    fprintf('  Universal test failed with value -1\n');
                % For universal test, avoid using 1.0 if other values are available
                elseif strcmp(testName, 'universal') && length(resultValues) > 1 && any(resultValues ~= 1.0)
                    nonOnes = resultValues(resultValues ~= 1.0);
                    pValues.(testName) = nonOnes(1);
                    passStatus.(testName) = nonOnes(1) > 0.01;
                    fprintf('  Using non-1.0 p-value for %s: %f\n', testName, nonOnes(1));
                else
                    pValues.(testName) = resultValues(1);
                    passStatus.(testName) = resultValues(1) > 0.01;
                    fprintf('  Using p-value for %s: %f\n', testName, resultValues(1));
                end
            end
        else
            fprintf('  No valid p-values found for %s\n', testName);
        end
    end
    
    % Print final results
    fprintf('\nFinal p-values:\n');
    for i = 1:length(selectedTests)
        testName = selectedTests{i};
        if isfield(pValues, testName) && ~isnan(pValues.(testName))
            if passStatus.(testName)
                resultStr = 'PASS';
            else
                resultStr = 'FAIL';
            end
            fprintf('%s: %f (%s)\n', testName, pValues.(testName), resultStr);
        else
            fprintf('%s: ERROR\n', testName);
        end
    end
end

function [numbers, positions] = extractNumbersFromString(str)
    % Extract all numeric values from a string
    numbers = [];
    positions = [];
    
    % Regular expression for floating point numbers (handles negative numbers, 0.123 and .123 formats)
    pattern = '-?\d*\.?\d+';
    [starts, ends] = regexp(str, pattern);
    
    for i = 1:length(starts)
        numStr = str(starts(i):ends(i));
        num = str2double(numStr);
        if ~isnan(num)
            numbers = [numbers, num];
            positions = [positions; [starts(i), ends(i)]];
        end
    end
end

function results = callNistTestsPy(inputFile, bitLength, selectedTests, offset)
    % Call NIST tests using MATLAB's Python interface
    try
        % Make sure the module is imported (or reimported)
        py.importlib.invalidate_caches();
        nist_module = py.importlib.import_module('nist_tests_wrapper2');
        
        % Convert MATLAB cell array to Python list
        pyTests = py.list(selectedTests);
        
        % Call the Python function to run the tests with offset
        if nargin < 4
            offset = 0;
        end
        
        % Format a structured message for the results
        methodInfo = 'Method: Python Interface';
        fileInfo = ['Input file: ' inputFile];
        lengthInfo = ['Bits used: ' num2str(bitLength) ' (offset: ' num2str(offset) ')'];
        header = ['=== ' methodInfo ' ===' newline fileInfo newline lengthInfo newline];
        
        % Call the Python function
        pyResults = nist_module.run_selected_tests(inputFile, int32(bitLength), pyTests, int32(offset));
        
        % Convert Python string to MATLAB string and add header
        results = [header char(pyResults)];
    catch e
        % Rethrow with more diagnostic information
        error('Python execution error: %s\n%s', e.message, getReport(e));
    end
end

function results = callNistTestsDirect(inputFile, bitLength, selectedTests, offset)
    % Call NIST tests using direct system command
    % This is a fallback method if the Python interface fails
    
    % Create a temporary file to store the results
    tempFile = [tempname, '.txt'];
    
    % Format the command
    testsStr = strjoin(selectedTests, ',');
    
    % Add offset parameter if provided
    if nargin < 4
        offset = 0;
    end
    offsetParam = sprintf(' --offset %d', offset);
    
    % Determine Python command based on OS
    if ispc
        pythonCmd = 'python';
    else
        pythonCmd = 'python3';
    end
    
    cmd = sprintf('%s nist_tests_wrapper2.py "%s" %d "%s"%s > "%s"', ...
                 pythonCmd, inputFile, bitLength, testsStr, offsetParam, tempFile);
    
    % Format a structured message for the results
    methodInfo = 'Method: Direct System Call';
    fileInfo = ['Input file: ' inputFile];
    lengthInfo = ['Bits used: ' num2str(bitLength) ' (offset: ' num2str(offset) ')'];
    cmdInfo = ['Command: ' cmd];
    header = ['=== ' methodInfo ' ===' newline fileInfo newline lengthInfo newline cmdInfo newline];
    
    % Execute the command
    [status, cmdout] = system(cmd);
    
    if status == 0
        % Read the results
        if exist(tempFile, 'file')
            fileID = fopen(tempFile, 'r');
            fileContent = fscanf(fileID, '%c');
            fclose(fileID);
            results = [header fileContent];
        else
            results = [header 'Success, but no output file was created.'];
        end
    else
        % Return the command output as it may contain error information
        results = [header 'Error executing Python script (status code: ' num2str(status) '). Command output:' newline cmdout];
    end
    
    % Clean up
    if exist(tempFile, 'file')
        delete(tempFile);
    end
end

function saveResults(~, ~)
    % Save the results to a file
    fig = gcf;
    userData = get(fig, 'UserData');
    results = userData.lastResults;
    
    if isempty(results)
        msgbox('No results to save.', 'Save Error', 'error');
        return;
    end
    
    [filename, pathname] = uiputfile({'*.txt', 'Text Files (*.txt)'; ...
                                     '*.csv', 'CSV Files (*.csv)'; ...
                                     '*.*', 'All Files (*.*)'}, ...
                                     'Save Results As');
    if filename ~= 0
        fileID = fopen(fullfile(pathname, filename), 'w');
        fprintf(fileID, '%s', results);
        fclose(fileID);
        msgbox('Results saved successfully.', 'Save Success', 'help');
    end
end
