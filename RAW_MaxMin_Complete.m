% File: RAW_MaxMin_Complete.m

classdef RAW_MaxMin_Complete
    %% Configuration Class
    properties (Constant)
        DEFAULT_GROUP_DURATION = 100; % ms
        DEFAULT_SLOTS = 8;
        DEFAULT_SIMULATION_TIME = 1000; % ms
    end
    
    properties
        nGroups
        nStations
        arrivalRate
        groupDuration
        nSlots
        trafficLoad
        assignment
        throughput
        simulationTime
    end
    
    %% Constructor and Main Methods
    methods
        function obj = RAW_MaxMin_Complete(nGroups, nStations, arrivalRate)
            % Initialize configuration
            obj.nGroups = nGroups;
            obj.nStations = nStations;
            obj.arrivalRate = arrivalRate;
            obj.groupDuration = obj.DEFAULT_GROUP_DURATION;
            obj.nSlots = obj.DEFAULT_SLOTS;
            obj.simulationTime = obj.DEFAULT_SIMULATION_TIME;
            
            % Validate configuration
            obj.validateConfiguration();
        end
        
        function obj = runSimulation(obj)
            % Main simulation flow
            fprintf('Starting simulation...\n');
            
            % Generate traffic
            obj.trafficLoad = obj.generatePoissonTraffic();
            
            % Run Max-Min scheduling
            [obj.assignment, obj.throughput] = obj.maxMinScheduling();
            
            % Analyze and display results
            obj.analyzePerformance();
            
            fprintf('Simulation completed.\n');
        end
    end
    
    %% Core Functionality Methods
    methods
        function traffic = generatePoissonTraffic(obj)
            % Generate Poisson distributed traffic for each station
            traffic = poissrnd(obj.arrivalRate, [obj.nStations, 1]);
        end
        
        function [assignment, throughput] = maxMinScheduling(obj)
            % Initialize variables
            assignment = zeros(obj.nStations, obj.nGroups);
            groupLoads = zeros(obj.nGroups, 1);
            unassignedStations = 1:obj.nStations;
            
            % Main Max-Min algorithm loop
            while ~isempty(unassignedStations)
                % Find group with minimum load
                [~, minGroup] = min(groupLoads);
                
                % Find station with maximum traffic
                [maxTraffic, maxIdx] = max(obj.trafficLoad(unassignedStations));
                stationToAssign = unassignedStations(maxIdx);
                
                % Assign station to group
                assignment(stationToAssign, minGroup) = 1;
                groupLoads(minGroup) = groupLoads(minGroup) + maxTraffic;
                
                % Update unassigned stations
                unassignedStations(maxIdx) = [];
            end
            
            % Calculate throughput
            throughput = obj.calculateThroughput(assignment);
        end
        
        function throughput = calculateThroughput(obj, assignment)
            throughput = zeros(obj.nGroups, 1);
            
            for group = 1:obj.nGroups
                % Get stations in current group
                groupStations = find(assignment(:, group));
                nStationsInGroup = length(groupStations);
                
                if nStationsInGroup > 0
                    % Calculate probabilities
                    slotProb = 1/obj.nSlots;
                    collisionProb = obj.calculateCollisionProbability(nStationsInGroup, slotProb);
                    successProb = (1 - collisionProb);
                    
                    % Calculate group throughput
                    groupTraffic = sum(obj.trafficLoad(groupStations));
                    throughput(group) = groupTraffic * successProb;
                end
            end
        end
        
        function prob = calculateCollisionProbability(~, nStations, slotProb)
            prob = 1 - (1 - slotProb)^(nStations - 1);
        end
    end
    
    %% Analysis and Visualization Methods
    methods
        function analyzePerformance(obj)
            % Calculate metrics
            avgThroughput = mean(obj.throughput);
            fairness = obj.calculateFairnessIndex();
            
            % Display metrics
            fprintf('\nPerformance Metrics:\n');
            fprintf('Average Throughput: %.2f packets/sec\n', avgThroughput);
            fprintf('Fairness Index: %.2f\n', fairness);
            
            % Plot results
            obj.plotResults();
        end
        
        function fairness = calculateFairnessIndex(obj)
            % Calculate Jain's fairness index
            numerator = sum(obj.throughput)^2;
            denominator = obj.nGroups * sum(obj.throughput.^2);
            fairness = numerator / denominator;
        end
        
        function plotResults(obj)
            figure('Name', 'RAW Max-Min Results', 'NumberTitle', 'off');
            
            % Plot 1: Assignment Matrix
            subplot(2,2,1);
            imagesc(obj.assignment);
            colormap('jet');
            colorbar;
            title('Station-to-Group Assignment');
            xlabel('RAW Groups');
            ylabel('Stations');
            
            % Plot 2: Throughput Distribution
            subplot(2,2,2);
            bar(obj.throughput);
            title('Throughput per RAW Group');
            xlabel('RAW Groups');
            ylabel('Throughput (packets/sec)');
            
            % Plot 3: Traffic Distribution
            subplot(2,2,3);
            histogram(obj.trafficLoad);
            title('Traffic Distribution');
            xlabel('Number of Packets');
            ylabel('Frequency');
            
            % Plot 4: Cumulative Performance
            subplot(2,2,4);
            plot(cumsum(sort(obj.throughput, 'descend')));
            title('Cumulative Throughput');
            xlabel('Number of Groups');
            ylabel('Cumulative Throughput');
        end
    end
    
    %% Utility Methods
    methods (Access = private)
        function validateConfiguration(obj)
            % Validate input parameters
            assert(obj.nGroups > 0, 'Number of groups must be positive');
            assert(obj.nStations > 0, 'Number of stations must be positive');
            assert(obj.arrivalRate > 0, 'Arrival rate must be positive');
            assert(obj.nSlots > 0, 'Number of slots must be positive');
            assert(obj.groupDuration > 0, 'Group duration must be positive');
        end
    end
end

%% Example Usage Script
% Add this at the end of the file as a comment, or save separately

% Example usage:
%{
% Create simulation instance
sim = RAW_MaxMin_Complete(4, 100, 5);

% Run simulation
sim.runSimulation();

% Access results
assignment = sim.assignment;
throughput = sim.throughput;

% Custom analysis
fprintf('Total network throughput: %.2f packets/sec\n', sum(throughput));
%}

%% Parameter Sweep Example
%{
% Parameter ranges
nStationsRange = [50, 100, 150, 200];
nGroupsRange = [2, 4, 6, 8];
arrivalRates = [1, 3, 5, 7];

% Initialize results storage
results = struct('nStations', {}, 'nGroups', {}, 'arrivalRate', {}, ...
                'avgThroughput', {}, 'fairness', {});

% Run parameter sweep
for s = 1:length(nStationsRange)
    for g = 1:length(nGroupsRange)
        for r = 1:length(arrivalRates)
            % Create and run simulation
            sim = RAW_MaxMin_Complete(nGroupsRange(g), nStationsRange(s), arrivalRates(r));
            sim.runSimulation();
            
            % Store results
            idx = length(results) + 1;
            results(idx).nStations = nStationsRange(s);
            results(idx).nGroups = nGroupsRange(g);
            results(idx).arrivalRate = arrivalRates(r);
            results(idx).avgThroughput = mean(sim.throughput);
            results(idx).fairness = sim.calculateFairnessIndex();
        end
    end
end

% Display results table
resultsTable = struct2table(results);
disp(resultsTable);
%}
