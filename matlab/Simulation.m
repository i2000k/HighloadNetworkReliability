classdef Simulation
    
    properties
        simDuration    % Модельное время, с
        monteCarloRuns % Количество прогонов Монте-Карло
        
        % Количества узлов сети в различных сегментах
        CLIENTS_SIZE = 48;
        CL_NODES_SIZE = 6;
        TR_ZONE_ROUTERS_SIZE = 2;
        O_ZONE_ROUTERS_SIZE = 1;
        CORE_ZONE_NODES_SIZE = 5;
        BAL_ZONE1_NODES_SIZE = 3;
        TR_SERV_ZONE_NODES_SIZE = 2;
        BAL_ZONE2_NODES_SIZE = 3;
        GLOBAL_NODES_SIZE = 13;
        TOTAL_NODES_SIZE = 70;
        
        SERV_NODES = [69, 70];      % Индексы конечных обрабатывающих узлов
        
        % Количества соединений в различных сегментах
        CLIENTS_CONNECTIONS_SIZE = 48;
        LOCAL_CONNECTIONS_SIZE = 13;
        GLOBAL_CONNECTIONS_SIZE = 24;
        TOTAL_CONNECTIONS_SIZE = 85;
        
        BUFFER_CAPACITY = 100;                  % Емкость буфера в узлах
        PROCESSING_TIME = 1;                    % Время обработки кадров в узле, с
        
        % CLIENT_INTESITY = 0.25;               % Интенсивность исходящих от клиентов кадров
        CLIENT_FREQ_MIN = 0.2;                  % Нижняя граница интенсивности исходящих от клиентов кадров
        CLIENT_FREQ_MAX = 0.25;                 % Верхняя граница интенсивности исходящих от клиентов кадров
        V_THRESHOLD = 0.1;                      % Порог интенсивности приходящих клиентам кадров (v_in > V_THRESHOLD * v_out) ? 1 : 0
        TIMESTEP = 60;                          % Шаг модельного времени, с
        S2_CRITICAL = 0.9;                      % Пороговое значение доли клиентов, получающих кадры для перехода в состояние S2
        S3_CRITICAL = 0.5;                      % Пороговое значение доли клиентов, получающих кадры для перехода в состояние S3
        SERVICE_TIME = 180;                     % Время обслуживания, с
        SERVICE_PERIOD = 2700;                  % Период обслуживания, с
        REPAIR_TEAMS = 5;                       % Количество бригад для обслуживания оборудования
        
        NODE_DEFAULT_FAILURE_RATE = 1e-6;       % Интенсивность отказов узлов по умолчанию
        NODE_DEFAULT_MEAN_RECOVERY_TIME = 60;   % Среднее время восстановления узлов по умолчанию
        NODE_DEFAULT_DETECTION_TIME = 10;       % Среднее время обнаружения отказа по умолчанию
        NODE_DEFAULT_REACTION_TIME = 10;        % Среднее время реакции на отказ по умолчанию
        NODE_DEFAULT_BANDWIDTH = 100 * 1e6;     % Пропускная способность узлов по умолчанию
        
        NODE_CLIENT_FAILURE_RATE = 0;           % Интенсивность отказов клиентов
        NODE_CL_FAILURE_RATE = 7e-6;            % Интенсивность отказов узлов в CL
        NODE_TR_FAILURE_RATE = 6e-6;            % Интенсивность отказов узлов в TR
        NODE_O_FAILURE_RATE = 1e-2;             % Интенсивность отказов узлов в O
        NODE_CORE_FAILURE_RATE = 4e-6;          % Интенсивность отказов узлов в CORE
        NODE_BAL_FAILURE_RATE = 3e-6;           % Интенсивность отказов узлов в BAL
        NODE_ST_FAILURE_RATE = 2e-6;            % Интенсивность отказов узлов в ST
        NODE_SER_FAILURE_RATE = 1e-6;           % Интенсивность отказов узлов в SER
        
        NODE_CLIENT_MEAN_RECOVERY_TIME = 0;     % Среднее время восстановления клиентов
        NODE_CL_MEAN_RECOVERY_TIME = 100;       % Среднее время восстановления узлов в CL
        NODE_TR_MEAN_RECOVERY_TIME = 120;       % Среднее время восстановления узлов в TR
        NODE_O_MEAN_RECOVERY_TIME = 140;        % Среднее время восстановления узлов в O
        NODE_CORE_MEAN_RECOVERY_TIME = 160;     % Среднее время восстановления узлов в CORE
        NODE_BAL_MEAN_RECOVERY_TIME = 180;      % Среднее время восстановления узлов в BAL
        NODE_ST_MEAN_RECOVERY_TIME = 180;       % Среднее время восстановления узлов в ST
        NODE_SER_MEAN_RECOVERY_TIME = 200;      % Среднее время восстановления узлов в SER
        
        NODE_CL_BANDWIDTH = 100 * 1e6;          % Пропускная способность узлов в CL
        NODE_TR_BANDWIDTH = 100 * 1e6;          % Пропускная способность узлов в TR
        NODE_O_BANDWIDTH = 100 * 1e6;           % Пропускная способность узлов в O
        NODE_CORE_BANDWIDTH = 100 * 1e6;        % Пропускная способность узлов в CORE
        NODE_BAL_BANDWIDTH = 100 * 1e6;         % Пропускная способность узлов в BAL
        NODE_ST_BANDWIDTH = 100 * 1e6;          % Пропускная способность узлов в ST
        NODE_SER_BANDWIDTH = 100 * 1e6;         % Пропускная способность узлов в SER
        
        CONN_DEFAULT_FAILURE_RATE = 2e-6;       % Интенсивность отказов соединений по умолчанию
        CONN_DEFAULT_MEAN_RECOVERY_TIME = 60;   % Среднее время восстановления соединений по умолчанию
        CONN_DEFAULT_DETECTION_TIME = 10;       % Среднее время обнаружения отказа соединений по умолчанию
        CONN_DEFAULT_REACTION_TIME = 10;        % Среднее время реакции на отказ соединений по умолчанию
        
        CONN_DEFAULT_BANDWIDTH = 100 * 1e6;     % Пропускная способность кабеля, Байт/с
        
        CONN_CL_FAILURE_RATE = 0;               % Интенсивность отказов соединений в CL
        CONN_LOC_FAILURE_RATE = 7e-6;           % Интенсивность отказов соединений в LOC
        CONN_GL_FAILURE_RATE = 6e-6;            % Интенсивность отказов соединений в GL
        
        CONN_CL_MEAN_RECOVERY_TIME = 0;         % Среднее время восстановления соединений в CL
        CONN_LOC_MEAN_RECOVERY_TIME = 100;      % Среднее время восстановления соединений в LOC
        CONN_GL_MEAN_RECOVERY_TIME = 120;       % Среднее время восстановления соединений в GL
        
        CONN_CL_BANDWIDTH = 100 * 1e6;          % Среднее время восстановления соединений в CL
        CONN_LOC_BANDWIDTH = 120 * 1e6;         % Среднее время восстановления соединений в LOC
        CONN_GL_BANDWIDTH = 140 * 1e6;          % Среднее время восстановления соединений в GL
        
        PACKET_DEFAULT_SIZE = 1500;             % Размер пакета по умолчанию, байт
    end
    
    methods
        function obj = Simulation(simDuration, monteCarloRuns)
            if nargin < 2
                obj.simDuration = 2678400;
                obj.monteCarloRuns = 10;
            else
                obj.simDuration = simDuration;
                obj.monteCarloRuns = monteCarloRuns;
            end
            
        end
        
        function obj = runSimulation(obj)
            topology = obj.createTopology();
            zonesInfo = obj.createZones();
            connectionZonesInfo = obj.createConnectionZones();
            
            params = struct();
            params.bufferCapacity = obj.BUFFER_CAPACITY;
            params.processingTime = obj.PROCESSING_TIME;
            params.failureRate = obj.NODE_DEFAULT_FAILURE_RATE;
            params.meanRecoveryTime = obj.NODE_DEFAULT_MEAN_RECOVERY_TIME;
            params.detectionTime = obj.NODE_DEFAULT_DETECTION_TIME;
            params.reactionTime = obj.NODE_DEFAULT_REACTION_TIME;
            params.nodeBandwidth = obj.NODE_DEFAULT_BANDWIDTH;
            
            params.bandwidth = obj.CONN_DEFAULT_BANDWIDTH;
            params.connFailureRate = obj.CONN_DEFAULT_FAILURE_RATE;
            params.connRecoveryTime = obj.CONN_DEFAULT_MEAN_RECOVERY_TIME;
            params.connDetectionTime = obj.CONN_DEFAULT_DETECTION_TIME;
            params.serverNodes = obj.SERV_NODES; % Номера серверных узлов
            params.numClients = obj.CLIENTS_SIZE;
            % params.clientIntensity = obj.CLIENT_INTESITY; % Интенсивность выходящих пакетов от узлов
            params.clientFreqMin = obj.CLIENT_FREQ_MIN;
            params.clientFreqMax = obj.CLIENT_FREQ_MAX;
            params.vThreshold = obj.V_THRESHOLD;
            params.simDuration = obj.simDuration;
            params.packetSize = obj.PACKET_DEFAULT_SIZE;
            % params.sendingInterval = 10;
            params.timeStep = obj.TIMESTEP;
            params.s2Critical =obj.S2_CRITICAL;
            params.s3Critical = obj.S3_CRITICAL;
            params.serviceTime = obj.SERVICE_TIME;
            params.servicePeriod = obj.SERVICE_PERIOD;
            params.repairTeamsTotal = obj.REPAIR_TEAMS;
            
            availabilityResults = struct('T0_1', cell(1, obj.monteCarloRuns), ...
                'T0_2', [], ...
                'Tv_1', [], ...
                'Tv_2', [], ...
                'lambda_12', [], ...
                'lambda_13', [], ...
                'lambda_21', [], ...
                'lambda_23', [], ...
                'lambda_31', [], ...
                'lambda_32', [], ...
                'Kg_1', [], ...
                'Kg_2', [], ...
                'elapsedTime', []);
            
            mcRuns = obj.monteCarloRuns;
            tic;
            parfor exp = 1:mcRuns
                tic;
                fprintf('Iteration: %d/%d\n', exp, mcRuns);
                model = NetworkModel();
                model.initializeNetwork(exp, topology, zonesInfo, connectionZonesInfo, params);
                
                [T0_1, T0_2, Tv_1, Tv_2, lambda_12, ...,
                    lambda_13, lambda_21, lambda_23, ...,
                    lambda_31, lambda_32] = model.startSimulation();
                
                % Сохранение результатов текущего прогона
                availabilityResults(exp).T0_1 = T0_1;
                availabilityResults(exp).T0_2 = T0_2;
                availabilityResults(exp).Tv_1 = Tv_1;
                availabilityResults(exp).Tv_2 = Tv_2;
                availabilityResults(exp).lambda_12 = lambda_12;
                availabilityResults(exp).lambda_13 = lambda_13;
                availabilityResults(exp).lambda_21 = lambda_21;
                availabilityResults(exp).lambda_23 = lambda_23;
                availabilityResults(exp).lambda_31 = lambda_31;
                availabilityResults(exp).lambda_32 = lambda_32;
                
                elapsedTime = toc;
                availabilityResults(exp).elapsedTime = elapsedTime;
                fprintf('[Exp %d] Эксперимент %d выполнен за: %.4f s\n', exp, exp, elapsedTime);
            end
            
            % Расчет средних значений по всем прогонам
            meanResults = struct();
            meanResults.T0_1 = mean([availabilityResults.T0_1]);
            meanResults.T0_2 = mean([availabilityResults.T0_2]);
            meanResults.Tv_1 = mean([availabilityResults.Tv_1]);
            meanResults.Tv_2 = mean([availabilityResults.Tv_2]);
            
            meanResults.lambda_12 = mean([availabilityResults.lambda_12]);
            meanResults.lambda_13 = mean([availabilityResults.lambda_13]);
            meanResults.lambda_21 = mean([availabilityResults.lambda_21]);
            meanResults.lambda_23 = mean([availabilityResults.lambda_23]);
            meanResults.lambda_31 = mean([availabilityResults.lambda_31]);
            meanResults.lambda_32 = mean([availabilityResults.lambda_32]);
            
            deltaSumResults = struct();
            
            deltaSumResults.T0_1 = obj.calculateDeltaSum(meanResults.T0_1, [availabilityResults.T0_1]);
            deltaSumResults.T0_2 = obj.calculateDeltaSum(meanResults.T0_2, [availabilityResults.T0_2]);
            deltaSumResults.Tv_1 = obj.calculateDeltaSum(meanResults.Tv_1, [availabilityResults.Tv_1]);
            deltaSumResults.Tv_2 = obj.calculateDeltaSum(meanResults.Tv_2, [availabilityResults.Tv_2]);
            
            deltaSumResults.lambda_12 = obj.calculateDeltaSum(meanResults.lambda_12, [availabilityResults.lambda_12]);
            deltaSumResults.lambda_13 = obj.calculateDeltaSum(meanResults.lambda_13, [availabilityResults.lambda_13]);
            deltaSumResults.lambda_21 = obj.calculateDeltaSum(meanResults.lambda_21, [availabilityResults.lambda_21]);
            deltaSumResults.lambda_23 = obj.calculateDeltaSum(meanResults.lambda_23, [availabilityResults.lambda_23]);
            deltaSumResults.lambda_31 = obj.calculateDeltaSum(meanResults.lambda_31, [availabilityResults.lambda_31]);
            deltaSumResults.lambda_32 = obj.calculateDeltaSum(meanResults.lambda_32, [availabilityResults.lambda_32]);
            
            meanKg1 = meanResults.T0_1 / (meanResults.T0_1 + meanResults.Tv_1);
            meanKg2 = meanResults.T0_2 / (meanResults.T0_2 + meanResults.Tv_2);
            
            Kg_1_values = [availabilityResults.T0_1] ./ ([availabilityResults.T0_1] + [availabilityResults.Tv_1]);
            Kg_2_values = [availabilityResults.T0_2] ./ ([availabilityResults.T0_2] + [availabilityResults.Tv_2]);
            
            elapsedTotalTime = toc;
            
            fprintf('\n=== Средние результаты после %d прогонов ===\n', mcRuns);
            fprintf('T0_1: %.2f ± %.2f\n', meanResults.T0_1, std([availabilityResults.T0_1]));
            fprintf('T0_2: %.2f ± %.2f\n', meanResults.T0_2, std([availabilityResults.T0_2]));
            fprintf('Tv_1: %.2f ± %.2f\n', meanResults.Tv_1, std([availabilityResults.Tv_1]));
            fprintf('Tv_2: %.2f ± %.2f\n', meanResults.Tv_2, std([availabilityResults.Tv_2]));
            
            fprintf('\nСредний коэффициент готовности:\n');
            fprintf('Kg1: %.4f\n', meanKg1);
            fprintf('Kg2: %.4f\n', meanKg2);
            
            obj.plotResults(availabilityResults, Kg_1_values, Kg_2_values)
            
            % Логирование результатов в файл
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            filename = sprintf('simulation_results_%s.txt', timestamp);
            fileID = fopen(filename, 'w');
            
            % Заголовок с параметрами симуляции
            fprintf(fileID, '=== Параметры симуляции ===\n');
            fprintf(fileID, 'Длительность: %d сек\n', obj.simDuration);
            fprintf(fileID, 'Количество прогонов: %d\n', obj.monteCarloRuns);
            fprintf(fileID, 'Шаг времени: %d сек\n', obj.TIMESTEP);
            
            % 2. Параметры сети
            fprintf(fileID, '\n=== Параметры сети ===\n');
            fprintf(fileID, 'Клиенты: %d\n', obj.CLIENTS_SIZE);
            fprintf(fileID, 'CL узлы: %d\n', obj.CL_NODES_SIZE);
            fprintf(fileID, 'TR маршрутизаторы: %d\n', obj.TR_ZONE_ROUTERS_SIZE);
            fprintf(fileID, 'O маршрутизаторы: %d\n', obj.O_ZONE_ROUTERS_SIZE);
            fprintf(fileID, 'CORE узлы: %d\n', obj.CORE_ZONE_NODES_SIZE);
            fprintf(fileID, 'BAL зона 1: %d\n', obj.BAL_ZONE1_NODES_SIZE);
            fprintf(fileID, 'TR SERV зона: %d\n', obj.TR_SERV_ZONE_NODES_SIZE);
            fprintf(fileID, 'BAL зона 2: %d\n', obj.BAL_ZONE2_NODES_SIZE);
            fprintf(fileID, 'GLOBAL узлы: %d\n', obj.GLOBAL_NODES_SIZE);
            fprintf(fileID, 'Всего узлов: %d\n', obj.TOTAL_NODES_SIZE);
            fprintf(fileID, 'Серверные узлы: %s\n', mat2str(obj.SERV_NODES));
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'Клиентские соединения: %d\n', obj.CLIENTS_CONNECTIONS_SIZE);
            fprintf(fileID, 'Локальные соединения: %d\n', obj.LOCAL_CONNECTIONS_SIZE);
            fprintf(fileID, 'Глобальные соединения: %d\n', obj.GLOBAL_CONNECTIONS_SIZE);
            fprintf(fileID, 'Всего соединений: %d\n', obj.TOTAL_CONNECTIONS_SIZE);
            fprintf(fileID, '\n');
            
            fprintf(fileID, '=== Параметры производительности ===\n');
            fprintf(fileID, 'Ёмкость буфера: %d\n', obj.BUFFER_CAPACITY);
            fprintf(fileID, 'Время обработки: %d\n', obj.PROCESSING_TIME);
            fprintf(fileID, 'Интенсивность клиентов: [%.2f %.2f] пак/сек\n', obj.CLIENT_FREQ_MIN, obj.CLIENT_FREQ_MAX);
            fprintf(fileID, 'Размер пакета: %d байт\n', obj.PACKET_DEFAULT_SIZE);
            fprintf(fileID, 'V порог: %.1f\n', obj.V_THRESHOLD);
            fprintf(fileID, 'S2 критический: %.1f\n', obj.S2_CRITICAL);
            fprintf(fileID, 'S3 критический: %.1f\n', obj.S3_CRITICAL);
            fprintf(fileID, 'Время обслуживания: %d сек\n', obj.SERVICE_TIME);
            fprintf(fileID, 'Период обслуживания: %d сек\n', obj.SERVICE_PERIOD);
            fprintf(fileID, '\n');
            
            fprintf(fileID, '=== Параметры надежности узлов ===\n');
            fprintf(fileID, 'По умолчанию:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_DEFAULT_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_DEFAULT_MEAN_RECOVERY_TIME);
            fprintf(fileID, '  Время обнаружения: %d сек\n', obj.NODE_DEFAULT_DETECTION_TIME);
            fprintf(fileID, '  Время реакции: %d сек\n', obj.NODE_DEFAULT_REACTION_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'CL узлы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_CL_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_CL_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'TR маршрутизаторы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_TR_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_TR_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'O маршрутизаторы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_O_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_O_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'CORE узлы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_CORE_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_CORE_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'BAL узлы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_BAL_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_BAL_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'ST узлы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_ST_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_ST_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'Серверные узлы:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.NODE_SER_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.NODE_SER_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            % 5. Параметры надежности соединений
            fprintf(fileID, '=== Параметры надежности соединений ===\n');
            fprintf(fileID, 'По умолчанию:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.CONN_DEFAULT_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.CONN_DEFAULT_MEAN_RECOVERY_TIME);
            fprintf(fileID, '  Время обнаружения: %d сек\n', obj.CONN_DEFAULT_DETECTION_TIME);
            fprintf(fileID, '  Время реакции: %d сек\n', obj.CONN_DEFAULT_REACTION_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'Клиентские соединения:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.CONN_CL_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.CONN_CL_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'Локальные соединения:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.CONN_LOC_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.CONN_LOC_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            fprintf(fileID, 'Глобальные соединения:\n');
            fprintf(fileID, '  Интенсивность отказов: %.2e\n', obj.CONN_GL_FAILURE_RATE);
            fprintf(fileID, '  Среднее время восстановления: %d сек\n', obj.CONN_GL_MEAN_RECOVERY_TIME);
            fprintf(fileID, '\n');
            
            % результаты каждого прогона
            fprintf(fileID, '\nИндивидуальные результаты прогонов:\n');
            fprintf(fileID, 'Run\tT0_1\tT0_2\tTv_1\tTv_2\tlambda_12\tlambda_13\tlambda_21\tlambda_23\tlambda_31\tlambda_32\tВремя\n');
            for exp = 1:obj.monteCarloRuns
                fprintf(fileID, '%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.2f', ...
                    exp, ...
                    availabilityResults(exp).T0_1, ...
                    availabilityResults(exp).T0_2, ...
                    availabilityResults(exp).Tv_1, ...
                    availabilityResults(exp).Tv_2, ...
                    availabilityResults(exp).lambda_12, ...
                    availabilityResults(exp).lambda_13, ...
                    availabilityResults(exp).lambda_21, ...
                    availabilityResults(exp).lambda_23, ...
                    availabilityResults(exp).lambda_31, ...
                    availabilityResults(exp).lambda_32, ...
                    availabilityResults(exp).elapsedTime);
                fprintf(fileID, '\n');
            end
            
            % средние результаты
            fprintf(fileID, '\n\nСредние результаты:\n');
            fprintf(fileID, 'Параметр\tСреднее\tСтанд. отклонение\n');
            fprintf(fileID, 'T0_1\t\t%.2f\t\t%.2f\n', meanResults.T0_1, std([availabilityResults.T0_1]));
            fprintf(fileID, 'T0_2\t\t%.2f\t\t%.2f\n', meanResults.T0_2, std([availabilityResults.T0_2]));
            fprintf(fileID, 'Tv_1\t\t%.2f\t\t%.2f\n', meanResults.Tv_1, std([availabilityResults.Tv_1]));
            fprintf(fileID, 'Tv_2\t\t%.2f\t\t%.2f\n', meanResults.Tv_2, std([availabilityResults.Tv_2]));
            
            fprintf(fileID, '\nСредние интенсивности переходов:\n');
            fprintf(fileID, 'lambda_12\t\t%.4f\t%.4f\n', mean([availabilityResults.lambda_12]), std([availabilityResults.lambda_12]));
            fprintf(fileID, 'lambda_13\t\t%.4f\t%.4f\n', mean([availabilityResults.lambda_13]), std([availabilityResults.lambda_13]));
            fprintf(fileID, 'lambda_21\t\t%.4f\t%.4f\n', mean([availabilityResults.lambda_21]), std([availabilityResults.lambda_21]));
            fprintf(fileID, 'lambda_23\t\t%.4f\t%.4f\n', mean([availabilityResults.lambda_23]), std([availabilityResults.lambda_23]));
            fprintf(fileID, 'lambda_31\t\t%.4f\t%.4f\n', mean([availabilityResults.lambda_31]), std([availabilityResults.lambda_31]));
            fprintf(fileID, 'lambda_32\t\t%.4f\t%.4f\n', mean([availabilityResults.lambda_32]), std([availabilityResults.lambda_32]));
            
            fprintf(fileID, '\nСуммы квадратов отклонений от среднего:\n');
            fprintf(fileID, 'T0_1\t\t%.2f\n', deltaSumResults.T0_1);
            fprintf(fileID, 'T0_2\t\t%.2f\n', deltaSumResults.T0_2);
            fprintf(fileID, 'Tv_1\t\t%.2f\n', deltaSumResults.Tv_1);
            fprintf(fileID, 'Tv_2\t\t%.2f\n', deltaSumResults.Tv_2);
            
            fprintf(fileID, 'lambda_12\t\t%.4f\n', deltaSumResults.lambda_12);
            fprintf(fileID, 'lambda_13\t\t%.4f\n', deltaSumResults.lambda_13);
            fprintf(fileID, 'lambda_21\t\t%.4f\n', deltaSumResults.lambda_21);
            fprintf(fileID, 'lambda_23\t\t%.4f\n', deltaSumResults.lambda_23);
            fprintf(fileID, 'lambda_31\t\t%.4f\n', deltaSumResults.lambda_31);
            fprintf(fileID, 'lambda_32\t\t%.4f\n', deltaSumResults.lambda_32);
            
            fprintf(fileID, '\nСредний Коэффициент готовности:\n');
            fprintf(fileID, 'Kg1: %.4f\n', meanKg1);
            fprintf(fileID, 'Kg2: %.4f\n', meanKg2);
            
            fprintf(fileID, '\nОбщее время выполнения: %.2f секунд (%.2f минут)\n', elapsedTotalTime, elapsedTotalTime/60);
            [~, systemMem] = memory;
            peakMem = systemMem.PhysicalMemory.Total - systemMem.PhysicalMemory.Available;
            fprintf(fileID, 'Пиковое использование памяти: %.d MB\n', round(peakMem / 1e6));
            fclose(fileID);
        end
        
        function [zonesInfo] = createZones(obj)
            
            zonesInfo = containers.Map();
            
            zonesInfo('CLIENT') = struct(...
                'nodeIdx', 1:48, ...
                'failureRate', obj.NODE_CLIENT_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_CLIENT_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_O_BANDWIDTH);
            
            zonesInfo('CL') = struct(...
                'nodeIdx', 49:54, ...
                'failureRate', obj.NODE_CL_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_CL_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_O_BANDWIDTH);
            
            zonesInfo('TR') = struct(...
                'nodeIdx', 55:56, ...
                'failureRate', obj.NODE_TR_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_TR_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_TR_BANDWIDTH);
            
            zonesInfo('O') = struct(...
                'nodeIdx', 57, ...
                'failureRate', obj.NODE_O_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_O_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_O_BANDWIDTH);
            
            zonesInfo('CORE') = struct(...
                'nodeIdx', 58:62, ...
                'failureRate', obj.NODE_CORE_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_CORE_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_CORE_BANDWIDTH);
            
            zonesInfo('BAL') = struct(...
                'nodeIdx', [63; 68], ...
                'failureRate', obj.NODE_BAL_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_BAL_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_BAL_BANDWIDTH);
            
            zonesInfo('ST') = struct(...
                'nodeIdx', [66; 67], ...
                'failureRate', obj.NODE_ST_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_ST_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_ST_BANDWIDTH);
            
            zonesInfo('SER') = struct(...
                'nodeIdx', [64; 65; 69; 70], ...
                'failureRate', obj.NODE_SER_FAILURE_RATE, ...
                'meanRecoveryTime', obj.NODE_SER_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.NODE_SER_BANDWIDTH);
        end
        
        function [zonesInfo] = createConnectionZones(obj)
            
            zonesInfo = containers.Map();
            
            zonesInfo('CL') = struct(...
                'failureRate', obj.CONN_CL_FAILURE_RATE, ...
                'meanRecoveryTime', obj.CONN_CL_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.CONN_CL_BANDWIDTH);
            
            zonesInfo('LOC') = struct(...
                'failureRate', obj.CONN_LOC_FAILURE_RATE, ...
                'meanRecoveryTime', obj.CONN_LOC_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.CONN_LOC_BANDWIDTH);
            
            zonesInfo('GL') = struct(...
                'failureRate', obj.CONN_GL_FAILURE_RATE, ...
                'meanRecoveryTime', obj.CONN_GL_MEAN_RECOVERY_TIME, ...
                'bandwidth', obj.CONN_GL_BANDWIDTH);
            
        end
        
        function [topology] = createTopology(obj)
            % Создаем верхний треугольник матрицы смежности
            topology = spalloc(obj.TOTAL_NODES_SIZE, obj.TOTAL_NODES_SIZE, obj.TOTAL_CONNECTIONS_SIZE); % Предварительное выделение памяти
            
            % Коммутатор 1
            topology(1:8,49) = true;
            topology(49,1:8) = true;
            topology(49, 50) = true;
            
            % Коммутатор 2
            topology(9:16,50) = true;
            topology(50,9:16) = true;
            topology(50, 49) = true;
            topology(50, 51) = true;
            
            
            % Коммутатор 3
            topology(17:24,51) = true;
            topology(51,17:24) = true;
            topology(51, 50) = true;
            
            % Коммутатор 4
            topology(25:32,52) = true;
            topology(52,25:32) = true;
            topology(52, 53) = true;
            
            % Коммутатор 5
            topology(33:40,53) = true;
            topology(53,33:40) = true;
            topology(53, 52) = true;
            topology(53, 54) = true;
            
            % Коммутатор 6
            topology(41:48,54) = true;
            topology(54,41:48) = true;
            topology(54, 53) = true;
            
            % Маршрутизатор 1
            topology(49:51,55) = true;
            topology(55,49:51) = true;
            topology(55, 56) = true;
            
            % Маршрутизатор 2
            topology(52:54,56) = true;
            topology(56,52:54) = true;
            topology(56, 55) = true;
            
            % Маршрутизатор 3
            topology(55:56,57) = true;
            topology(57,55:56) = true;
            
            % Маршрутизатор 4
            topology(57, 58) = true;
            topology(58, 57) = true;
            
            % Маршрутизатор 5
            topology(59, 58) = true;
            topology(58, 59) = true;
            topology(59, 60) = true;
            
            % Маршрутизатор 6
            topology(60, 58) = true;
            topology(58, 60) = true;
            topology(60, 59) = true;
            
            % Маршрутизатор 7
            topology(59:60, 61) = true;
            topology(61, 59:60) = true;
            topology(61, 62) = true;
            
            % Маршрутизатор 8
            topology(59:60, 62) = true;
            topology(62, 59:60) = true;
            topology(62, 61) = true;
            
            % Маршрутизатор 9
            topology(61:62, 63) = true;
            topology(63, 61:62) = true;
            
            % Маршрутизатор 10
            topology(64, 63) = true;
            topology(63, 64) = true;
            topology(64, 65) = true;
            
            % Маршрутизатор 11
            topology(65, 63) = true;
            topology(63, 65) = true;
            topology(65, 64) = true;
            
            % Маршрутизатор 12
            topology(66, 64:65) = true;
            topology(64:65, 66) = true;
            topology(66, 67) = true;
            
            % Маршрутизатор 13
            topology(67, 64:65) = true;
            topology(64:65, 67) = true;
            topology(67, 66) = true;
            
            % Маршрутизатор 14
            topology(68, 66:67) = true;
            topology(66:67, 68) = true;
            
            % Маршрутизатор 15
            topology(69, 68) = true;
            topology(68, 69) = true;
            topology(69, 70) = true;
            
            % Маршрутизатор 16
            topology(70, 68) = true;
            topology(68, 70) = true;
            topology(70, 69) = true;
            
            G = graph(topology);
            plot(G);
        end
        
        function obj = plotResults(obj, availabilityResults, Kg_1_values, Kg_2_values)
            timeStep = obj.TIMESTEP;
            
            % Построение гистограмм
            figure('Name', 'Распределение показателей надежности', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
            
            % 1. Гистограмма T0_1 и T0_2 с плавными кривыми
            subplot(2,2,1);
            
            % Ядро плотности для T0_1
            [f1, xi1] = ksdensity([availabilityResults.T0_1], 'Bandwidth', timeStep);
            plot(xi1, f1, 'b', 'LineWidth', 2);
            hold on;
            
            % Ядро плотности для T0_2
            [f2, xi2] = ksdensity([availabilityResults.T0_2], 'Bandwidth', timeStep);
            plot(xi2, f2, 'r', 'LineWidth', 2);
            
            histogram([availabilityResults.T0_1], 'BinWidth', timeStep, 'FaceColor', 'b', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Normalization', 'pdf');
            histogram([availabilityResults.T0_2], 'BinWidth', timeStep, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Normalization', 'pdf');
            
            hold off;
            title('Распределение наработки на отказ');
            xlabel('Время, с');
            ylabel('Плотность вероятности');
            legend('T0_1 (ядро)', 'T0_2 (ядро)', 'T0_1 (гист.)', 'T0_2 (гист.)', 'Location', 'northwest');
            grid on;
            
            
            subplot(2,2,2);
            
            % Ядро плотности для Tv_1
            [f1, xi1] = ksdensity([availabilityResults.Tv_1], 'Bandwidth', timeStep);
            plot(xi1, f1, 'b', 'LineWidth', 2);
            hold on;
            
            % Ядро плотности для Tv_2
            [f2, xi2] = ksdensity([availabilityResults.Tv_2], 'Bandwidth', timeStep);
            plot(xi2, f2, 'r', 'LineWidth', 2);
            
            histogram([availabilityResults.Tv_1], 'BinWidth', timeStep, 'FaceColor', 'b', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Normalization', 'pdf');
            histogram([availabilityResults.Tv_2], 'BinWidth', timeStep, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Normalization', 'pdf');
            
            hold off;
            title('Распределение времени восстановления');
            xlabel('Время, с');
            ylabel('Плотность вероятности');
            legend('Tv_1 (ядро)', 'Tv_2 (ядро)', 'Tv_1 (гист.)', 'Tv_2 (гист.)', 'Location', 'northwest');
            grid on;
            
            subplot(2,2,3);
            
            % Определяем оптимальный шаг для Kg (так как они в диапазоне [0,1])
            kgStep = max(0.01, timeStep/100); % Не менее 0.01
            
            % Ядро плотности для Kg_1
            [f1, xi1] = ksdensity(Kg_1_values, 'Bandwidth', kgStep);
            plot(xi1, f1, 'b', 'LineWidth', 2);
            hold on;
            
            % Ядро плотности для Kg_2
            [f2, xi2] = ksdensity(Kg_2_values, 'Bandwidth', kgStep);
            plot(xi2, f2, 'r', 'LineWidth', 2);
            
            histogram(Kg_1_values, 'BinWidth', kgStep, 'FaceColor', 'b', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Normalization', 'pdf');
            histogram(Kg_2_values, 'BinWidth', kgStep, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Normalization', 'pdf');
            
            hold off;
            title('Распределение коэффициентов готовности');
            xlabel('Значение коэффициента');
            ylabel('Плотность вероятности');
            legend('Kg_1 (ядро)', 'Kg_2 (ядро)', 'Kg_1 (гист.)', 'Kg_2 (гист.)', 'Location', 'northwest');
            xlim([0 1]);
            grid on;
        end
        
        
        function s = calculateDeltaSum(obj, meanVal, vals)
            s = 0;
            for i = 1:length(vals)
                s = s + power(meanVal - vals(i), 2);
            end
        end
    end
end

