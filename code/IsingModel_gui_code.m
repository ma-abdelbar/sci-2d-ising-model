classdef IsingModel < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        UIAxes                          matlab.ui.control.UIAxes
        StartButton                     matlab.ui.control.Button
        StopButton                      matlab.ui.control.Button
        TTcSliderLabel                  matlab.ui.control.Label
        TTcSlider                       matlab.ui.control.Slider
        MagnetisationperspinGaugeLabel  matlab.ui.control.Label
        MagnetisationperspinGauge       matlab.ui.control.SemicircularGauge
        SystemSizeEditFieldLabel        matlab.ui.control.Label
        SystemSizeEditField             matlab.ui.control.NumericEditField
        ExtrenalFieldinunitsofKSliderLabel  matlab.ui.control.Label
        ExtrenalFieldinunitsofKSlider   matlab.ui.control.Slider
    end

%   Author : Mohamed A. Abdelbar
%   Date   : 20/03/2018
%   Description : 
%   This is the code for an app which is used to demonstrate the Ising Model of phase transitions in ferromagnets.
%   It does this by making use of the metropolis algorithm.

    properties (Access = private)
        flag % This is a variable used to control the while loop using the start and stop buttons on the app.
        Temperature % Ratio between temperature and the critical temperature for the 2D Ising Model.
        mps % Net Magnetisation per spin
        eps % Energy per spin
        size % This variable is used so that the user can control the size of the lattice in the model.
        h % This is the user input for the external field strength in units of the boltzmann constant.
    end


    methods (Access = private)

        % Value changing function: ExtrenalFieldinunitsofKSlider
        function ExtrenalFieldinunitsofKSliderValueChanging(app, event)
            changingValue = event.Value;
            app.h = changingValue;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            %   Creating a random matrix of values -1 and 1
            app.size = app.SystemSizeEditField.Value;
            u = randi([0,1],app.size);
            u2 = 2.*u;
            s = u2 - 1;
            %   Initialization of parameters
            T = app.Temperature;    % Ratio of Temperature to the theoretical critical temperature according to the Ising Model.
            k = 1.38064852e-23;     % Boltzmann's Constant
            J = k/1.82;             % This value is chosen so that the critical temperature takes the value of 1.
            H = app.h.*k;           % The external field applied to the system.      
            app.flag = 1;           % To start running the simulation.
            step = 1;               
            % Metropolis Algorithm
            while app.flag == 1
                drawnow             % This is a command that ensures that all of the callbacks are taken into account while looping.
                T = app.Temperature;
                H = app.h.*k;       
                B = 1./(k.*T);              % The inverse temperature
                Ec = StateEnergyP(s,J,H);   % Current State Energy calculated using our function.
                ri = randi(app.size);       % Choose Random site (i,j)
                rj = randi(app.size);
                sp = s;                     % Create proposed new state
                sp(ri,rj) = -sp(ri,rj);     % Flip the random site's spin
                Ep = StateEnergyP(sp,J,H);  % Calculate the proposed state's energy
                if Ep > Ec
                    pa = exp(-B*(Ep - Ec)); % Calculate the probability of acceptance of the proposed state based on metropolis algorithm
                    x = rand;               % Generate random number between (0,1)
                    if x <= pa
                        s = sp;             % Accept the new state only with the acceptance probablity
                    end
                else
                    s = sp;                 % Always accept the new state if Ep<Ec
                end
                step = step + 1;
                % This section has to do with displaying the data. Here we choose the number of steps to display per new frame of the simulation.
                if mod(step,100) == 0
                    drawnow limitrate                              % This limits the framerates so that it saves computational power
                    imagesc(app.UIAxes,s)                          % This creates the plot based on the current microstate
                    app.UIAxes.XLim = [0.5 app.size+0.5];          % Sets the limits of the plot in order to adjust for user input  
                    app.UIAxes.YLim = [0.5 app.size+0.5];
                    M = abs(sum(sum(s)));                          % Calculates the total net magnetisation of the lattice
                    app.mps = M/(app.size.^2);                     % Calculates the magnetisation per spin.
                    app.MagnetisationperspinGauge.Value = app.mps; % Sends this value to the gauge on the app interface
                    app.eps = Ec/(app.size.^2);                    % Calculates the energy per spin
                    pause(0.0001)                                   % A quick pause in order to allow time to display the plot.
                end
            end
            
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            app.flag = 0;                    % Is used to break the while loop when the stop button is pushed on the app interface
        end

        % Value changing function: TTcSlider
        function TTcSliderValueChanging(app, event)
            changingValue = event.Value;
            app.Temperature = changingValue;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 776 506];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Lattice Cells')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.XLim = [0 1];
            app.UIAxes.YLim = [0 1];
            app.UIAxes.CLim = [0 1];
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [15 30 474 399];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [15 467 100 22];
            app.StartButton.Text = 'Start';

            % Create StopButton
            app.StopButton = uibutton(app.UIFigure, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Position = [15 437 100 22];
            app.StopButton.Text = 'Stop';

            % Create TTcSliderLabel
            app.TTcSliderLabel = uilabel(app.UIFigure);
            app.TTcSliderLabel.HorizontalAlignment = 'right';
            app.TTcSliderLabel.Position = [256 474 27 15];
            app.TTcSliderLabel.Text = 'T/Tc';

            % Create TTcSlider
            app.TTcSlider = uislider(app.UIFigure);
            app.TTcSlider.Limits = [1e-07 3];
            app.TTcSlider.MajorTickLabels = {'0', '0.2', '0.4', '0.6', '0.8', '1', '1.2', '1.4', '1.6', '1.8', '2', '2.2', '2.4', '2.6', '3'};
            app.TTcSlider.ValueChangingFcn = createCallbackFcn(app, @TTcSliderValueChanging, true);
            app.TTcSlider.Position = [304 480 447 3];
            app.TTcSlider.Value = 1;

            % Create MagnetisationperspinGaugeLabel
            app.MagnetisationperspinGaugeLabel = uilabel(app.UIFigure);
            app.MagnetisationperspinGaugeLabel.HorizontalAlignment = 'center';
            app.MagnetisationperspinGaugeLabel.Position = [562 165 129 15];
            app.MagnetisationperspinGaugeLabel.Text = 'Magnetisation per spin';

            % Create MagnetisationperspinGauge
            app.MagnetisationperspinGauge = uigauge(app.UIFigure, 'semicircular');
            app.MagnetisationperspinGauge.Limits = [0 0.2];
            app.MagnetisationperspinGauge.Position = [535 195 183 99];

            % Create SystemSizeEditFieldLabel
            app.SystemSizeEditFieldLabel = uilabel(app.UIFigure);
            app.SystemSizeEditFieldLabel.HorizontalAlignment = 'center';
            app.SystemSizeEditFieldLabel.Position = [150 474 72 15];
            app.SystemSizeEditFieldLabel.Text = 'System Size';

            % Create SystemSizeEditField
            app.SystemSizeEditField = uieditfield(app.UIFigure, 'numeric');
            app.SystemSizeEditField.Limits = [10 200];
            app.SystemSizeEditField.HorizontalAlignment = 'center';
            app.SystemSizeEditField.Position = [136 445 100 22];
            app.SystemSizeEditField.Value = 50;

            % Create ExtrenalFieldinunitsofKSliderLabel
            app.ExtrenalFieldinunitsofKSliderLabel = uilabel(app.UIFigure);
            app.ExtrenalFieldinunitsofKSliderLabel.HorizontalAlignment = 'right';
            app.ExtrenalFieldinunitsofKSliderLabel.Position = [556 390 146 15];
            app.ExtrenalFieldinunitsofKSliderLabel.Text = 'Extrenal Field in units of K';

            % Create ExtrenalFieldinunitsofKSlider
            app.ExtrenalFieldinunitsofKSlider = uislider(app.UIFigure);
            app.ExtrenalFieldinunitsofKSlider.Limits = [-0.05 0.05];
            app.ExtrenalFieldinunitsofKSlider.ValueChangingFcn = createCallbackFcn(app, @ExtrenalFieldinunitsofKSliderValueChanging, true);
            app.ExtrenalFieldinunitsofKSlider.Position = [502 377 249 3];
        end
    end

    methods (Access = public)

        % Construct app
        function app = IsingModel

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end