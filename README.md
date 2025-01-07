# IEEE 802.11ah RAW Max-Min Scheduler Implementation

[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A MATLAB implementation of Max-Min scheduling algorithm for Restricted Access Window (RAW) in IEEE 802.11ah networks, featuring Poisson traffic distribution and comprehensive performance analysis.

## Features

- RAW Scheduling with Max-Min fairness algorithm
- Dynamic station-to-group assignment
- Poisson traffic distribution
- Collision probability calculation
- Throughput and fairness analysis
- Visual performance metrics
- Parameter sweep capability

## Prerequisites

- MATLAB R2019b or later
- Statistics and Machine Learning Toolbox
- Communications Toolbox (optional)

## Quick Start

```matlab
% Create simulation instance
sim = RAW_MaxMin_Complete(4, 100, 5);  % nGroups, nStations, arrivalRate

% Run simulation
sim.runSimulation();
```
Basic congig:
```
sim = RAW_MaxMin_Complete(nGroups, nStations, arrivalRate);
sim.runSimulation();
```
Advanced Configuration:
```
sim = RAW_MaxMin_Complete(6, 150, 7);
sim.groupDuration = 200;  % ms
sim.nSlots = 16;         % slots per group
sim.runSimulation();
```
Parameter Sweep:
```
nStationsRange = [50, 100, 150, 200];
nGroupsRange = [2, 4, 6, 8];
arrivalRates = [1, 3, 5, 7];

results = struct();
idx = 1;

for s = nStationsRange
    for g = nGroupsRange
        for r = arrivalRates
            sim = RAW_MaxMin_Complete(g, s, r);
            sim.runSimulation();
            results(idx).stations = s;
            results(idx).groups = g;
            results(idx).rate = r;
            results(idx).throughput = mean(sim.throughput);
            results(idx).fairness = sim.calculateFairnessIndex();
            idx = idx + 1;
        end
    end
end
```


Method	                 Description
runSimulation()	         Execute complete simulation
maxMinScheduling()	     Perform scheduling algorithm
calculateThroughput()	   Calculate network throughput
analyzePerformance()	   Generate performance metrics
plotResults()	           Visualize results

Example:
```
sim = RAW_MaxMin_Complete(4, 100, 5);
sim.runSimulation();
fprintf('Average Throughput: %.2f packets/sec\n', mean(sim.throughput));
fprintf('Fairness Index: %.2f\n', sim.calculateFairnessIndex());
```









