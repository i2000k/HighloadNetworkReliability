classdef Connection < handle
    properties
        from                % Начальный узел соединения
        to                  % Конечный узел соединения
        bandwidth           % Пропускная способность (бит /с)
        failureRate         % Интенсивность отказов (λ)
        meanRecoveryTime    % Среднее время восстановления
        detectionTime       % Время обнаружения отказа
        isFailed            % Флаг состояния отказа (true/false)
        nextFailureTime     % Время следующего отказа
        nextRecoveryTime    % Время следующего восстановления
        recoveryStartTime   % Время начала следующего восстановления
        name                % строковое имя соединения
        zone                % Имя зоны в которой находится кабель
        
    end
    
    methods
        function obj = Connection(name, from, to, bandwidth, failureRate, meanRecoveryTime, detectionTime)
            % Конструктор класса Connection
            
            % Конструктор по умолчанию
            if nargin == 0
                % obj.name = 'Unnamed connection';
                % obj.from = [];
                % obj.to = [];
                % obj.bandwidth = 100 * 1e6;               % По умолчанию 100 Мбит/с
                % obj.failureRate = 1e-6;                  % λ = 0.000001
                % obj.meanRecoveryTime = 5;                % Среднее время восстановления = 5
                % obj.detectionTime = 1;
                % obj.isFailed = false;
                % obj = obj.scheduleNextFailure(0);         % Планируем первый отказ
                % obj.nextRecoveryTime = NaN;              % Пока нет отказа
                error('Невозможно создать Connection: не хватает параметров.')
                
                % Конструктор с параметрами
            elseif nargin == 7
                obj.name = name;
                obj.from = from;
                obj.to = to;
                obj.bandwidth = bandwidth;
                obj.failureRate = failureRate;
                obj.meanRecoveryTime = meanRecoveryTime;
                obj.detectionTime = detectionTime;
                obj.isFailed = false;
                obj = obj.scheduleNextFailure(0);   % Планируем первый отказ
                obj.nextRecoveryTime = NaN;         % Пока нет отказа
                
            else
                error('Error creating Connection object. Too low arguments.');
            end
        end
        
        function obj = scheduleNextFailure(obj, currentTime)
            % Планирование времени следующего отказа (экспоненциальное распределение)
            obj.nextFailureTime = currentTime + exprnd(1 / obj.failureRate);
        end
        
        function obj = scheduleRecovery(obj)
            % Планирование времени восстановления (экспоненциальное распределение)
            if obj.isFailed
                obj.recoveryStartTime = obj.nextFailureTime + obj.detectionTime;
                obj.nextRecoveryTime = obj.recoveryStartTime + obj.meanRecoveryTime;
            end
        end
        
        function obj = simulateFailure(obj, currentTime)
            % Моделирование отказа соединения
            if ~obj.isFailed && currentTime >= obj.nextFailureTime
                obj.isFailed = true;
                obj = obj.scheduleRecovery(currentTime);
            end
        end
        
        function obj = simulateRecovery(obj, currentTime)
            % Моделирование восстановления соединения
            if obj.isFailed && currentTime >= obj.nextRecoveryTime
                obj.isFailed = false;
                obj = obj.scheduleNextFailure();
                obj.nextRecoveryTime = NaN;
            end
        end
        
        function available = isAvailable(obj)
            % Проверка доступности соединения
            available = ~obj.isFailed;
        end
        
        function isAvailable = wasAvailableAt(obj, checkTime)
            % Проверяет, был ли узел доступен в указанный момент времени
            % checkTime - время, для которого проверяется доступность
            
            % Если узел не отказал вообще
            if isnan(obj.nextFailureTime)
                isAvailable = true;
                return;
            end
            
            % Если проверяемое время раньше первого отказа
            if checkTime < obj.nextFailureTime
                isAvailable = true;
                return;
            end
            
            % Если узел уже отказал, но еще не восстановился
            if obj.isFailed && checkTime < obj.nextRecoveryTime
                isAvailable = false;
                return;
            end
            
            % Если узел восстановился после отказа
            if ~obj.isFailed && checkTime >= obj.nextRecoveryTime
                isAvailable = true;
                return;
            end
            
            % По умолчанию считаем узел доступным
            isAvailable = true;
        end
        
        function transmitPacket(obj, packet)
            % Время передачи пакета через это соединение
            transmissionTime = packet.size / obj.bandwidth;
            packet.addTransmissionTime(transmissionTime);
            
            % Возвращаем общее время передачи
            totalTime = transmissionTime;
        end
    end
end

