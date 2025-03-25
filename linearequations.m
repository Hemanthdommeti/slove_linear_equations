classdef LinearEquationSolver < matlab.apps.AppBase
    
    % Public properties for app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        EquationTypeDropDown matlab.ui.control.DropDown
        InputPanel           matlab.ui.container.Panel
        SolveButton          matlab.ui.control.Button
        ResultTextArea       matlab.ui.control.TextArea
        
        % Edit fields for equation inputs
        EditFields           struct
    end
    
    % Private methods for solving equations
    methods (Access = private)
        
        function setupInputFields(app)
            % Dynamically create input fields based on equation type
            delete(get(app.InputPanel, 'Children'));
            
            % Get selected equation type
            equationType = app.EquationTypeDropDown.Value;
            
            % Clear previous edit fields
            app.EditFields = struct();
            
            switch equationType
                case 'Single Variable'
                    createSingleVariableInputs(app);
                case 'Two Variable System'
                    createTwoVariableInputs(app);
                case 'Three Variable System'
                    createThreeVariableInputs(app);
            end
        end
        
        function createSingleVariableInputs(app)
            % Create input fields for single variable equation (ax + b = 0)
            labels = {'a (coefficient)', 'b (constant)'};
            for i = 1:2
                uilabel(app.InputPanel, ...
                    'Position', [20, 200 - (i-1)*50, 150, 22], ...
                    'Text', labels{i});
                
                app.EditFields.(['Field' num2str(i)]) = uieditfield(app.InputPanel, 'numeric', ...
                    'Position', [180, 200 - (i-1)*50, 100, 22], ...
                    'Value', 0);
            end
        end
        
        function createTwoVariableInputs(app)
            % Create input fields for two-variable system (ax + by = c, dx + ey = f)
            labels = {'a', 'b', 'c', 'd', 'e', 'f'};
            for i = 1:6
                uilabel(app.InputPanel, ...
                    'Position', [20 + 200*floor((i-1)/3), 200 - mod(i-1,3)*50, 50, 22], ...
                    'Text', labels{i});
                
                app.EditFields.(['Field' num2str(i)]) = uieditfield(app.InputPanel, 'numeric', ...
                    'Position', [80 + 200*floor((i-1)/3), 200 - mod(i-1,3)*50, 100, 22], ...
                    'Value', 0);
            end
        end
        
        function createThreeVariableInputs(app)
            % Create input fields for three-variable system
            labels = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'};
            for i = 1:9
                uilabel(app.InputPanel, ...
                    'Position', [20 + 200*floor((i-1)/3), 200 - mod(i-1,3)*50, 50, 22], ...
                    'Text', labels{i});
                
                app.EditFields.(['Field' num2str(i)]) = uieditfield(app.InputPanel, 'numeric', ...
                    'Position', [80 + 200*floor((i-1)/3), 200 - mod(i-1,3)*50, 100, 22], ...
                    'Value', 0);
            end
        end
        
        function solveEquation(app, ~)
            % Main solving method with error handling
            try
                equationType = app.EquationTypeDropDown.Value;
                
                switch equationType
                    case 'Single Variable'
                        solveSingleVariable(app);
                    case 'Two Variable System'
                        solveTwoVariableSystem(app);
                    case 'Three Variable System'
                        solveThreeVariableSystem(app);
                end
            catch ME
                % Display error message
                app.ResultTextArea.Value = ['Error: ' ME.message];
            end
        end
        
        function solveSingleVariable(app)
            % Solve single variable linear equation
            a = app.EditFields.Field1.Value;
            b = app.EditFields.Field2.Value;
            
            if a == 0
                if b == 0
                    result = 'Infinite solutions';
                else
                    result = 'No solution';
                end
            else
                x = -b / a;
                result = sprintf('x = %.4f', x);
            end
            
            app.ResultTextArea.Value = result;
        end
        
        function solveTwoVariableSystem(app)
            % Solve two-variable linear system
            a = app.EditFields.Field1.Value;
            b = app.EditFields.Field2.Value;
            c = app.EditFields.Field3.Value;
            d = app.EditFields.Field4.Value;
            e = app.EditFields.Field5.Value;
            f = app.EditFields.Field6.Value;
            
            A = [a, b; d, e];
            B = [c; f];
            
            % Check for singularity
            if det(A) == 0
                result = 'No unique solution (Singular matrix)';
            else
                X = A \ B;
                result = sprintf('x = %.4f, y = %.4f', X(1), X(2));
            end
            
            app.ResultTextArea.Value = result;
        end
        
        function solveThreeVariableSystem(app)
            % Solve three-variable linear system
            A = [app.EditFields.Field1.Value, app.EditFields.Field2.Value, app.EditFields.Field3.Value;
                 app.EditFields.Field4.Value, app.EditFields.Field5.Value, app.EditFields.Field6.Value;
                 app.EditFields.Field7.Value, app.EditFields.Field8.Value, app.EditFields.Field9.Value];
            
            B = [app.EditFields.Field3.Value;
                 app.EditFields.Field6.Value;
                 app.EditFields.Field9.Value];
            
            % Check for singularity
            if det(A) == 0
                result = 'No unique solution (Singular matrix)';
            else
                X = A \ B;
                result = sprintf('x = %.4f, y = %.4f, z = %.4f', X(1), X(2), X(3));
            end
            
            app.ResultTextArea.Value = result;
        end
    end
    
    % App Initialization and Construction
    methods (Access = public)
        
        function app = LinearEquationSolver
            % Constructor
            createComponents(app);
            registerApp(app, app.UIFigure);
            
            % Initial setup
            setupInputFields(app);
            
            if nargout == 0
                clear app
            end
        end
        
        function delete(app)
            % Destructor
            delete(app.UIFigure);
        end
    end
    
    % Component Creation Method
    methods (Access = private)
        
        function createComponents(app)
            % Create main figure
            app.UIFigure = uifigure('Position', [100, 100, 500, 400], ...
                'Name', 'Advanced Linear Equation Solver', ...
                'Resize', 'off');
            
            % Equation Type Dropdown
            uilabel(app.UIFigure, 'Position', [50, 350, 150, 22], 'Text', 'Select Equation Type:');
            app.EquationTypeDropDown = uidropdown(app.UIFigure, ...
                'Position', [210, 350, 200, 22], ...
                'Items', {'Single Variable', 'Two Variable System', 'Three Variable System'}, ...
                'Value', 'Single Variable', ...
                'ValueChangedFcn', @(dd,event) setupInputFields(app));
            
            % Input Panel
            app.InputPanel = uipanel(app.UIFigure, ...
                'Position', [50, 100, 400, 230], ...
                'Title', 'Equation Inputs');
            
            % Solve Button
            app.SolveButton = uibutton(app.UIFigure, 'push', ...
                'Text', 'Solve', ...
                'Position', [200, 50, 100, 30], ...
                'ButtonPushedFcn', @(btn,event) solveEquation(app));
            
            % Result Text Area
            app.ResultTextArea = uitextarea(app.UIFigure, ...
                'Position', [50, 10, 400, 30], ...
                'Value', 'Enter values and press Solve', ...
                'Editable', 'off');
        end
    end
end
