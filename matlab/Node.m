classdef Node < handle
    properties
        id                  % индекс узла
        requestBuffer       % входящий Буфер узла (Packet[])
        responseBuffer      % исходящий Буфер узла (Packet[])
        bufferCapacity      % Вместимость буфера
        processingBandwidth      % Время обработки, с
        failureRate         % Интенсивность отказов
        meanRecoveryTime    % Время восстановления, с
        detectionTime       % Время обнаружения отказа, с
        isFailed            % Флаг состояния отказа (true/false)
        nextFailureTime     % Время следующего отказа, с
        nextRecoveryTime    % Время следующего восстановления, с
        connections         % Соединения узла
        isClientNode        % является клиентом (true/false)
        isClientSent        % флаг, определяющий отправлял ли клиент в заданный промежуток времени кадры (true/false)
        zone                % Название зоны узла (String)
        lastReqBufferProcessTime = 0;   % Последнее время обработки исходящего буфера
        lastResBufferProcessTime = 0;   % Последнее время обработки входящего буфера
        network
        recoveryStartTime = 0;
        
        % sendIntensity_history
        % receiveIntensity_history
        
        packetStats = struct(...        % статистика передаваемых и получаемых пакетов
            'totalSent', 0, ...         % Всего отправлено пакетов
            'totalReceived', 0, ...     % Всего получено пакетов
            'lastIntensityTime', 0, ...  % Время последнего расчета интенсивности
            'sendIntensity', 0,   ...    % Текущая интенсивность отправки
            'receiveIntensity', 0  ...   % Текущая интенсивность получения
            );
        
        
    end
    
    methods
        function obj = Node(id, bufferCapacity, processingBandwidth, failureRate, meanRecoveryTime, detectionTime, network)
            if nargin == 0
                % obj.id = 0;
                % obj.requestBuffer = [];
                % obj.responseBuffer = [];
                % obj.bufferCapacity = 10;
                % obj.processingTime = 1;
                % obj.failureRate = 1e-6;
                % obj.meanRecoveryTime = 5;
                % obj.detectionTime = 1;
                % obj.isFailed = false;
                % obj = obj.scheduleNextFailure(0);
                % obj.nextRecoveryTime = NaN;
                % obj.connections = Connection.empty();
                % obj.isClientNode = false;
                % obj.isClientSent = false;
                % % Инициализация статистики
                % obj.packetStats = struct(...
                %     'totalSent', 0, ...
                %     'totalReceived', 0, ...
                %     'lastIntensityTime', 0, ...  % Время последнего расчета интенсивности
                %     'sendIntensity', 0,   ...    % Текущая интенсивность отправки
                %     'receiveIntensity', 0  ...   % Текущая интенсивность получения
                %     );
                error('Невозможно создать Node: не хватает параметров.')
                
            elseif nargin == 7
                obj.id = id;
                obj.requestBuffer = [];  % Инициализация пустого буфера
                obj.responseBuffer = [];
                obj.bufferCapacity = bufferCapacity;
                obj.processingBandwidth = processingBandwidth;
                obj.failureRate = failureRate;
                obj.meanRecoveryTime = meanRecoveryTime;
                obj.detectionTime = detectionTime;
                obj.isFailed = false;  % Изначально узел работает
                obj = obj.scheduleNextFailure(0);
                obj.nextRecoveryTime = NaN;
                obj.connections = Connection.empty();
                obj.isClientNode = false;
                obj.isClientSent = false;
                obj.network = network;
                % Инициализация статистики
                obj.packetStats = struct(...
                    'totalSent', 0, ...
                    'totalReceived', 0, ...
                    'lastIntensityTime', 0, ...  % Время последнего расчета интенсивности
                    'sendIntensity', 0,   ...    % Текущая интенсивность отправки
                    'receiveIntensity', 0  ...   % Текущая интенсивность получения
                    );
                
                % obj.sendIntensity_history = [];
                % obj.receiveIntensity_history = [];

                % obj.sendIntensity_history(1) = 0;
                % obj.receiveIntensity_history(1) = 0;
                
            else
                error('Error creating Node object. Too low arguments.');
            end
        end
        
        function obj = scheduleNextFailure(obj, currentTime)
            % Генерирует время до следующего отказа по экспоненциальному закону
            % nextFailureTime = текущее время + случайное время отказа (exprnd(1/λ))
            obj.nextFailureTime = currentTime + exprnd(1 / obj.failureRate);
        end
        
        function obj = scheduleRecovery(obj)
            % Генерирует время восстановления по экспоненциальному закону
            % nextRecoveryTime = текущее время + случайное время восстановления (exprnd(meanRecoveryTime))
            if obj.isFailed
                obj.recoveryStartTime = obj.nextFailureTime + obj.detectionTime;
                obj.nextRecoveryTime = obj.recoveryStartTime + obj.meanRecoveryTime;
            end
        end
        
        function obj = simulateFailure(obj, currentTime)
            % Моделирует отказ узла, если currentTime >= nextFailureTime
            if ~obj.isFailed && currentTime >= obj.nextFailureTime
                obj.isFailed = true;
                obj = obj.scheduleRecovery(currentTime);
            end
        end
        
        function obj = simulateRecovery(obj, currentTime)
            % Моделирует восстановление узла, если currentTime >= nextRecoveryTime
            if obj.isFailed && currentTime >= obj.nextRecoveryTime
                obj.isFailed = false;
                obj = obj.scheduleNextFailure();  % Планируем следующий отказ
                obj.nextRecoveryTime = NaN;      % Сбрасываем время восстановления
            end
        end
        
        function available = isAvailable(obj)
            available = ~obj.isFailed;
        end
        
        % Не использовать для соединения узлов. Использовать только
        % connectNodes
        function obj = addConnection(obj, connection)
            % Добавление соединения к узлу
            if ~isa(connection, 'Connection')
                error('Добавляемый объект должен быть класса Connection');
            end
            
            obj.connections(end+1) = connection;
        end
        
        function [node1, node2, conn] = connectNodes(node1, node2, bandwidth, failureRate, meanRecoveryTime, detectionTime)
            % Проверяем, не соединены ли уже эти узлы
            if hasConnection(node1, node2.id) || hasConnection(node2, node1.id)
                error('Узлы уже соединены');
            end
            
            connName = [num2str(node1.id) '_' num2str(node2.id) '_link'];
            % Создаем объект Connection
            conn = Connection(connName, node1, node2, bandwidth, failureRate, meanRecoveryTime, detectionTime);
            
            % Добавляем ссылку на этот объект обоим узлам
            node1 = node1.addConnection(conn);
            node2 = node2.addConnection(conn);
        end
        
        function obj = removeConnection(obj, connection)
            
            % Проверяем, что соединение принадлежит этому узлу
            if ~any([obj.connections] == connection)
                error('Соединение не принадлежит данному узлу');
            end
            
            % Определяем противоположный узел
            if connection.from == obj
                otherNode = connection.to;
            else
                otherNode = connection.from;
            end
            
            % Удаляем соединение из текущего узла
            obj.connections([obj.connections] == connection) = [];
            
            % Удаляем соединение из противоположного узла
            otherNode.connections([otherNode.connections] == connection) = [];
        end
        
        function n = numConnections(obj)
            % Возвращает количество соединений узла
            n = numel(obj.connections);
        end
        
        function result = hasConnection(obj, targetNodeId)
            % Проверяет наличие соединения с указанным узлом
            result = false;
            for i = 1:numel(obj.connections)
                if (strcmp(obj.connections(i).from.id, obj.id) && ...
                        strcmp(obj.connections(i).to.id, targetNodeId)) || ...
                        (strcmp(obj.connections(i).to.id, obj.id) && ...
                        strcmp(obj.connections(i).from.id, targetNodeId))
                    result = true;
                    return;
                end
            end
        end
        
        function otherNode = getOtherNode(obj, connection)
            % Возвращает противоположный узел в соединении
            if strcmp(connection.from.id, obj.id)
                otherNode = connection.to;
            else
                otherNode = connection.from;
            end
        end
        
        function availableConnections = getAvailableConnections(obj, currentTime)
            tempConnections(obj.numConnections()) = Connection();
            count = 0;
            
            for i = 1:obj.numConnections()
                conn = obj.connections(i);
                if ~conn.isFailed % && obj.connections(i).isAvailable(currentTime)
                    count = count + 1;
                    tempConnections(count) = conn;
                end
            end
            
            availableConnections = tempConnections(1:count);
        end
        
        function sendPackets(obj, transNodes, destinationNode, packets, currentTime)
            if isempty(packets)
                return;
            end
            obj.recordSentPacket();
            packetSendTime = packets(1).sendTime;
            ttl = packets(1).ttl;
            subgraph = [obj, transNodes];
            route = obj.calculateRoute(subgraph, destinationNode, ttl, packetSendTime);
            
            % fprintf('Маршрут: %d -> %d:\n', obj.id, destinationNode.id);
            % ids = [route.id];                          % Извлекаем все id в вектор
            % idStrings = string(ids);                   % Преобразуем в строковый массив
            % routeStr = strjoin(idStrings, " -> ");       % Объединяем с разделителем
            % fprintf("%s\n", routeStr);                              % Выводим результат
            
            if isempty(route)
                error('Маршрут до узла %d не найден для времени %d', destinationNode.id, packetSendTime);
            end
            
            % % 2. Создаем пакеты
            % packets = Packet.createFromMessage(message, obj, destinationNode, "request", packetSize);
            
            % 3. Передаем каждый пакет
            for i = 1:length(packets)
                currentPacket = packets(i);
                currentPacket.route = route; % Сохраняем весь маршрут в пакете
                currentPacket.currentHop = 1; % Текущий шаг в маршруте
                
                % Устанавливаем следующий узел в маршруте
                % if length(route) > 1
                %     currentPacket.nextDestinationNode = route(2);
                % else
                %     currentPacket.nextDestinationNode = destinationNode;
                % end
                
                % Обновляем статистику отправки
                % obj.updateStats(currentTime, true);
                
                
                % Отправляем пакет первому узлу в маршруте
                obj.forwardPacketToNextHop(currentPacket, currentPacket.sendTime);
                
                % if connection.isFailed
                %     error('Соединение с %s не работает', destinationNode.id);
                % end
                
                % % Обновляем информацию о маршруте
                % packets(i).updateRouting(obj, destinationNode);
                %
                % % Передаем пакет
                % destinationNode.receivePacket(packets(i));
                %
                % fprintf('Узел %d отправил пакет %d/%d узлу %d\n', ...
                %     obj.id, i, length(packets), destinationNode.id);
            end
        end
        
        function route = calculateRoute(obj, allNodes, destinationNode, ttl, packetSendTime)
            % Реализация алгоритма поиска маршрута (Оптимизированный Дейкстра O(nlog⁡n+mlog⁡n))
            
            % Инициализация
            % distances = containers.Map('KeyType', 'int32', 'ValueType', 'double');
            % previous = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            
            nodeInfo = struct('id', {}, 'dist', {}, 'prev', {}, 'visited', {}, 'available', {});
            
            numNodes = length(allNodes);
            
            for i = 1:numNodes
                % % distances(allNodes(i).id) = Inf;
                % node = allNodes(i);
                % distances(node.id) = Inf;
                
                nodeInfo(i).id = allNodes(i).id;
                nodeInfo(i).dist = Inf;
                nodeInfo(i).prev = [];
                nodeInfo(i).visited = false;
                nodeInfo(i).available = allNodes(i).wasAvailableAt(packetSendTime);
                nodeInfo(i).nodeObj = allNodes(i); % Сохраняем ссылку на объект
            end
            %distances(obj.id) = 0;
            startIdx = find([nodeInfo.id] == obj.id);
            nodeInfo(startIdx).dist = 0;
            pq = PriorityQueue(numNodes);
            pq.insert(startIdx, 0);
            
            % Основной цикл алгоритма
            while ~pq.isEmpty()
                % Извлекаем узел с минимальным расстоянием
                [currentIdx, ~] = pq.extractMin();
                currentNodeInfo = nodeInfo(currentIdx);
                
                % Если достигли целевого узла
                if currentNodeInfo.id == destinationNode.id
                    break;
                end
                
                % Помечаем узел как посещенный
                nodeInfo(currentIdx).visited = true;
                
                % Пропускаем недоступные узлы
                if ~currentNodeInfo.available
                    continue;
                end
                
                % Получаем соседей текущего узла
                neighbors = getNeighbors(currentNodeInfo.nodeObj);
                
                % Обновляем расстояния до соседей
                for i = 1:length(neighbors)
                    neighbor = neighbors(i);
                    if neighbor.isClientNode
                        continue;
                    end
                    neighborIdx = find([nodeInfo.id] == neighbor.id);
                    neighborInfo = nodeInfo(neighborIdx);
                    
                    % Пропускаем недоступные узлы и соединения
                    if ~neighborInfo.available
                        continue;
                    end
                    
                    conn = currentNodeInfo.nodeObj.findConnectionTo(neighbor);
                    if ~conn.wasAvailableAt(packetSendTime)
                        continue;
                    end
                    
                    % Вычисляем новое расстояние
                    alt = currentNodeInfo.dist + 1; % Упрощенная метрика
                    
                    % Если нашли более короткий путь
                    if alt < neighborInfo.dist
                        nodeInfo(neighborIdx).dist = alt;
                        nodeInfo(neighborIdx).prev = currentNodeInfo.nodeObj;
                        
                        % Обновляем очередь
                        if pq.contains(neighborIdx)
                            pq.decreaseKey(neighborIdx, alt);
                        else
                            pq.insert(neighborIdx, alt);
                        end
                    end
                end
            end
            
            % Восстанавливаем маршрут
            route = Node.empty();
            destIdx = find([nodeInfo.id] == destinationNode.id);
            
            if ~isempty(destIdx) && ~isinf(nodeInfo(destIdx).dist)
                current = destinationNode;
                while ~isempty(current)
                    route = [current route];
                    prevNode = nodeInfo([nodeInfo.id] == current.id).prev;
                    current = prevNode;
                end
            end
            
            % Проверяем TTL и доступность маршрута
            if ~isempty(route) && ttl < length(route)-1
                route = Node.empty();
                return;
            end
            
            % Проверяем доступность всех узлов и соединений маршрута
            if ~isempty(route)
                for i = 1:length(route)
                    if ~route(i).wasAvailableAt(packetSendTime)
                        route = Node.empty();
                        return;
                    end
                end
                
                for i = 1:length(route)-1
                    conn = route(i).findConnectionTo(route(i+1));
                    if ~conn.wasAvailableAt(packetSendTime)
                        route = Node.empty();
                        return;
                    end
                end
            end
            
            %
            %
            % % Основной цикл алгоритма
            % while ~isempty(allNodes)
            %     % Находим узел с минимальным расстоянием
            %     [currentNode, allNodes] = getNodeWithMinDistance(allNodes, distances);
            %
            %     % Если достигли целевого узла или все узлы обработаны
            %     if isempty(currentNode) || currentNode.id == destinationNode.id
            %         break;
            %     end
            %
            %     % Пропускаем недоступные узлы
            %     if ~currentNode.wasAvailableAt(packetSendTime)
            %         continue;
            %     end
            %
            %     % Обновляем расстояния до соседей
            %     neighbors = getNeighbors(currentNode);
            %     for i = 1:length(neighbors)
            %         neighbor = neighbors(i);
            %
            %         conn = currentNode.findConnectionTo(neighbor);
            %          % Если соединение или соседний узел отказали, пропускаем
            %         if ~conn.wasAvailableAt(packetSendTime) || ~neighbor.wasAvailableAt(packetSendTime)
            %             continue;
            %         end
            %
            %         alt = distances(currentNode.id) + 1; % Упрощенная метрика
            %
            %         if alt < distances(neighbor.id)
            %             distances(neighbor.id) = alt;
            %             previous(neighbor.id) = currentNode;
            %         end
            %     end
            % end
            %
            % % Восстанавливаем маршрут
            % route = Node.empty();
            % if isKey(previous, destinationNode.id) || obj.id == destinationNode.id
            %     current = destinationNode;
            %     while ~isempty(current)
            %         route = [current route];
            %         if isKey(previous, current.id)
            %             current = previous(current.id);
            %         else
            %             current = [];
            %         end
            %     end
            % end
            %
            %  % Проверяем, что маршрут существует и не содержит отказавших узлов/соединений
            % if ~isempty(route)
            %    % Проверяем доступность всех узлов маршрута
            %     for i = 1:length(route)
            %         if ~route(i).wasAvailableAt(packetSendTime)
            %             route = Node.empty();
            %             break;
            %         end
            %     end
            %
            %     % Проверяем доступность всех соединений маршрута
            %     if ~isempty(route)
            %         for i = 1:length(route)-1
            %             conn = route(i).findConnectionTo(route(i+1));
            %             if ~conn.wasAvailableAt(packetSendTime)
            %                 route = Node.empty();
            %                 break;
            %             end
            %         end
            %     end
            %
            %     % Учет TTL
            %     if ~isempty(route) && ttl < length(route)-1
            %         route = Node.empty();
            %         return;
            %     end
            % end
        end
        
        function forwardPacketToNextHop(obj, packet, currentTime)
            % Пересылает пакет следующему узлу в маршруте
            
            % Добавляем время в предыдущей очереди
            packet.totalQueueTime = packet.totalQueueTime + packet.localQueueTime;
            currentTime = currentTime + packet.localQueueTime;
            packet.localQueueTime = 0;
            
            
            % Добавляем время обработки на текущем узле
            processingTime = packet.size / obj.processingBandwidth;
            packet.addProcessingTime(processingTime);
            currentTime = currentTime + processingTime;
            
            % nextHop = packet.nextDestinationNode;
            nextHop = packet.route(packet.currentHop + 1);
            if isempty(nextHop)
                error('Не указан следующий узел для пересылки');
            end
            
            % Проверяем, что следующий узел был доступен при отправке
            if ~nextHop.wasAvailableAt(packet.sendTime)
                error('Узел %d был недоступен в момент отправки %d', nextHop.id, packet.sendTime);
            end
            
            % Проверяем соединение
            connection = obj.findConnectionTo(nextHop);
            if isempty(connection)
                error('Нет соединения с узлом %d', nextHop.id);
            end
            
            % Проверяем, что соединение не отказало
            if ~connection.wasAvailableAt(packet.sendTime)
                error('Соединение с %d было недоступно в момент отправки %d', nextHop.id, packet.sendTime);
            end
            
            transmissionTime = packet.size / connection.bandwidth;
            packet.addTransmissionTime(transmissionTime);
            
            currentTime = currentTime + transmissionTime;
            
            
            if packet.isExpired(currentTime)
                error('Packet %d expired before forwarding (in transit for %.1f seconds)', ...
                    packet.id, currentTime - packet.sendTime);
            end
            
            % Обновляем информацию о маршруте
            % packet.lastSourceNode = obj;
            packet.currentHop = packet.currentHop + 1;
            
            
            % Если это не конечный узел, обновляем следующий пункт
            % if nextHop.id ~= packet.destination.id && packet.currentHop < length(packet.route)
            %     packet.nextDestinationNode = packet.route(packet.currentHop + 1);
            % end
            
            % Передаем пакет
            packet.ttl = packet.ttl - 1;
            if packet.ttl <= 0
                error('Packet TTL expired');
            end
            nextHop.receivePacket(packet, obj, currentTime);
            % nextHop.processBuffer();
            
            % Делаем в receivePacket
            % % Удаляем переданный пакет из буфера текущего узла
            % obj.removePacketFromBuffer(packet);
        end
        
        function neighbors = getNeighbors(obj)
            % Возвращает список соседних узлов
            neighbors = Node.empty();
            for i = 1:length(obj.connections)
                conn = obj.connections(i);
                if conn.from == obj
                    neighbors(end+1) = conn.to;
                else
                    neighbors(end+1) = conn.from;
                end
            end
            neighbors = unique(neighbors);
        end
        
        function allNodes = getNetworkNodes(obj)
            % Возвращает все узлы сети (упрощенная реализация)
            allNodes = Node.empty();
            nodesToProcess = obj;
            processedNodes = containers.Map('KeyType', 'int32', 'ValueType', 'logical');
            
            while ~isempty(nodesToProcess)
                current = nodesToProcess(1);
                nodesToProcess(1) = [];
                
                if ~isKey(processedNodes, current.id)
                    allNodes(end+1) = current;
                    processedNodes(current.id) = true;
                    
                    % Добавляем соседей
                    neighbors = current.getNeighbors();
                    for i = 1:length(neighbors)
                        if ~isKey(processedNodes, neighbors(i).id)
                            nodesToProcess(end+1) = neighbors(i);
                        end
                    end
                end
            end
        end
        
        function receivePacket(obj, packet, lastNode, currentTime)
            
            % queueTime = currentTime - packet.currentArrivalTime;
            % packet.addQueueTime(queueTime);
            packet.currentArrivalTime = currentTime;
            
            if packet.isExpired(currentTime)
                % Remove from previous node's buffer
                lastNode.removePacketFromBuffer(packet);
                error('Packet %d expired (in transit for %.1f seconds)', ...
                    packet.id, currentTime - packet.sendTime);
            end
            
            
            % Проверяем, является ли текущий узел конечным пунктом назначения
            if packet.destination == obj
                % Обработка полученного пакета в конечном узле
                obj.processPacket(packet, lastNode, currentTime);
                return;
            end
            
            % Проверка типа пакета (request, response)
            if strcmp(packet.direction, "request")
                % Проверка переполнения буфера
                if length(obj.requestBuffer) >= obj.bufferCapacity
                    % fprintf('Packet: from: %d to: %d, Буфер узла %d переполнен', packet.source.id, packet.destination.id, obj.id);
                    error('Request Буфер узла %d переполнен', obj.id);
                end
                obj.requestBuffer = [obj.requestBuffer, packet];
            else
                % Проверка переполнения буфера
                if length(obj.responseBuffer) >= obj.bufferCapacity
                    % fprintf('Packet: from: %d to: %d, Буфер узла %d переполнен', packet.source.id, packet.destination.id, obj.id);
                    error('Response Буфер узла %d переполнен', obj.id);
                end
                obj.responseBuffer = [obj.responseBuffer, packet];
            end
            
            % Удаляем из предыдущего буфера
            lastNode.removePacketFromBuffer(packet);
            
            % fprintf('[%d] Получил пакет %d от %d\n', ...
            %     obj.id, packet.id, packet.lastSourceNode.id);
            
            % Обновляем информацию о маршруте
            % packet.lastSourceNode = obj;
            
            % Обновляем статистику получения
            %obj.updateStats(currentTime, false)
            obj.recordReceivedPacket();
            
            packet.markQueueStart(currentTime);
            % начинаем обработку буферов
            obj.processBuffer(packet.direction, currentTime);
            
            
            % packet.nextDestinationNode = []; % Пока неизвестен следующий узел
        end
        
        function processBuffer(obj, direction, currentTime)
            if strcmp(direction, "request")
                while ~isempty(obj.requestBuffer)
                    % currentTime = obj.requestBuffer(1).sendTime + obj.requestBuffer(1).getTotalTime();
                    % if currentTime > globalTime + obj.timeStep
                    %     break
                    % end
                    % Рассчитываем время, прошедшее с последней обработки
                    % obj.lastReqBufferProcessTime = currentTime;
                    % Добавляем время ожидания всем пакетам в буфере
                    for i = 1:length(obj.requestBuffer)
                        obj.requestBuffer(i).addQueueTime(currentTime);
                    end
                    
                    packet = obj.requestBuffer(1);
                    try
                        if packet.isExpired(currentTime)
                            error('Packet %d expired (in transit for %.1f seconds)', ...
                                packet.id, currentTime - packet.sendTime);
                        end
                        
                        % Определяем следующий узел на маршруте
                        if packet.currentHop < length(packet.route)
                            nextHop = packet.route(packet.currentHop + 1);
                            connection = obj.findConnectionTo(nextHop);
                            if isempty(connection) || ~connection.wasAvailableAt(currentTime)
                                error('Connection to node %d is unavailable', nextHop.id);
                            end
                            
                            obj.forwardPacketToNextHop(packet, currentTime);
                        end
                    catch ME
                        % Обработка ошибок передачи
                        % fprintf('[%d] Ошибка пересылки пакета %d: %d, %s\n', ...
                        %     obj.id, packet.id, ME.message);
                        
                        % Удаляем проблемный пакет из буфера
                        obj.requestBuffer(1) = [];
                        obj.network.packetsLost = obj.network.packetsLost + 1;
                    end
                end
            else
                while ~isempty(obj.responseBuffer)
                    % currentTime = obj.responseBuffer(1).sendTime + obj.responseBuffer(1).getTotalTime();
                    % if currentTime > globalTime + obj.timeStep
                    %     break
                    % end
                    % obj.lastResBufferProcessTime = currentTime;
                    
                    % Добавляем время ожидания всем пакетам в буфере
                    for i = 1:length(obj.responseBuffer)
                        obj.responseBuffer(i).addQueueTime(currentTime);
                    end
                    
                    packet = obj.responseBuffer(1);
                    try
                        if packet.isExpired(currentTime)
                            error('Packet %d expired (in transit for %.1f seconds)', ...
                                packet.id, currentTime - packet.sendTime);
                        end
                        
                        % Определяем следующий узел на маршруте
                        if packet.currentHop < length(packet.route)
                            nextHop = packet.route(packet.currentHop + 1);
                            connection = obj.findConnectionTo(nextHop);
                            if isempty(connection) || ~connection.wasAvailableAt(currentTime)
                                error('Connection to node %d is unavailable', nextHop.id);
                            end
                            
                            obj.forwardPacketToNextHop(packet, currentTime);
                        end
                        
                    catch ME
                        % Обработка ошибок передачи
                        % fprintf('[%d] Ошибка пересылки пакета %d: %d, %s\n', ...
                        %    obj.id, packet.id, ME.message);
                        
                        % Удаляем проблемный пакет из буфера
                        % if contains(ME.message, 'expired')
                        %     fprintf('Packet %d expired: %s\n', packet.id, ME.message);
                        % end
                        obj.responseBuffer(1) = [];
                        obj.network.packetsLost = obj.network.packetsLost + 1;
                        
                    end
                end
            end
            
        end
        
        function processPacket(obj, packet, lastNode, currentTime)
            % Обработка пакета в конечном узле
            % fprintf('[%d] Пакет %d успешно доставлен от %d\n', ...
            %     obj.id, packet.id, packet.source.id);
            processingTime = packet.size / obj.processingBandwidth;
            packet.addProcessingTime(processingTime);
            currentTime = currentTime + processingTime;
            
            obj.recordReceivedPacket();
            
            % Если это клиентский узел, не пересылаем дальше (ответ)
            if obj.isClientNode
                % fprintf('[%d] Клиент успешно получил ответ от %d\n', ...
                %     obj.id, packet.source.id);
                lastNode.removePacketFromBuffer(packet);
                return;
            end
            
            lastNode.removePacketFromBuffer(packet);
            
            
            % Создаем ответное сообщение
            responseMessage = sprintf('Response to: %d', packet.source.id);
            
            % Создаем ответные пакеты
            % responsePackets = Packet.createFromMessage(...
            %     responseMessage, obj, packet.source, "response", packet.size);
            responsePacket = Packet(obj, packet.source, responseMessage, currentTime, "response", 'Size', packet.size);
            
            %Устанавливаем маршрут обратно
            % route = obj.calculateRoute(responsePacket.destination, responsePacket.ttl, currentTime);
            responsePacket.route = fliplr(packet.route);
            % responsePacket.route = route;
            % if length(route) > 1
            %     responsePacket.nextDestinationNode = route(2);
            % else
            %     responsePacket.nextDestinationNode = responsePacket.destination;
            % end
            
            % Отправляем пакет
            obj.forwardPacketToNextHop(responsePacket, currentTime);
            
            % Отправляем каждый пакет обратно
            % for i = 1:length(responsePackets)
            %     currentPacket = responsePackets(i);
            %
            %     % Устанавливаем маршрут обратно
            %     route = obj.calculateRoute(packet.source);
            %     if length(route) > 1
            %         currentPacket.nextDestinationNode = route(2);
            %     else
            %         currentPacket.nextDestinationNode = packet.source;
            %     end
            %
            %     % Отправляем пакет
            %     obj.forwardPacketToNextHop(currentPacket, currentTime);
            % end
        end
        
        function connection = findConnectionTo(obj, targetNode)
            % Ищем соединение с указанным узлом
            connection = [];
            for i = 1:length(obj.connections)
                conn = obj.connections(i);
                if (conn.from == obj && conn.to == targetNode) || ...
                        (conn.to == obj && conn.from == targetNode)
                    connection = conn;
                    return;
                end
            end
        end
        
        % function forwardPacket(obj, packet, nextNode)
        %     % Пересылка пакета следующему узлу
        %     connection = obj.findConnectionTo(nextNode);
        %     if isempty(connection)
        %         error('Нет соединения с узлом %d', nextNode.id);
        %     end
        %
        %     % Проверяем состояние соединения
        %     if connection.isFailed
        %         error('Соединение с %d не работает', nextNode.id);
        %     end
        %
        %     % Обновляем информацию о маршруте
        %     packet.updateRouting(obj, nextNode);
        %
        %     % Передаем пакет
        %     nextNode.receivePacket(packet, obj);
        %
        %     % 5. Удаляем переданный пакет из буфера текущего узла
        %     obj.removePacketFromBuffer(packet);
        %
        %
        %     fprintf('Узел %d переслал пакет узлу %d\n', ...
        %         obj.id, nextNode.id);
        % end
        
        function removePacketFromBuffer(obj, packet)
            if (strcmp(packet.direction, "request"))
                % Удаляет конкретный пакет из буфера
                for i = 1:length(obj.requestBuffer)
                    if obj.requestBuffer(i).isEqual(packet)
                        obj.requestBuffer(i) = [];
                        return;
                    end
                end
            else
                % Удаляет конкретный пакет из буфера
                for i = 1:length(obj.responseBuffer)
                    if obj.responseBuffer(i).isEqual(packet)
                        obj.responseBuffer(i) = [];
                        return;
                    end
                end
            end
            
            % warning('Пакет не найден в буфере узла %d', obj.id);
        end
        
        function recordSentPacket(obj)
            % Учет отправленного пакета
            obj.packetStats.totalSent = obj.packetStats.totalSent + 1;
        end
        
        function recordReceivedPacket(obj)
            % Учет полученного пакета
            obj.packetStats.totalReceived = obj.packetStats.totalReceived + 1;
        end
        
        function calculateIntensity(obj, currentTime, timeWindow)
            
            if currentTime - obj.packetStats.lastIntensityTime >= timeWindow
                timeElapsed = currentTime - obj.packetStats.lastIntensityTime;
                
                % Расчет интенсивности (пакетов в секунду)
                obj.packetStats.sendIntensity = obj.packetStats.totalSent / timeElapsed;
                obj.packetStats.receiveIntensity = obj.packetStats.totalReceived / timeElapsed;
                
                % Сброс счетчиков
                obj.packetStats.totalSent = 0;
                obj.packetStats.totalReceived = 0;
                obj.packetStats.lastIntensityTime = currentTime;
                
                % obj.sendIntensity_history(end+1) = obj.packetStats.sendIntensity;
                % obj.receiveIntensity_history(end+1) = obj.packetStats.receiveIntensity;
            end
            
            
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
    end
end

% Вспомогательная функция для алгоритма Дейкстра
% function [node, remainingNodes] = getNodeWithMinDistance(nodes, distances)
% % Самый быстрый вариант для небольших графов

% % minDist = Inf;
% % node = [];
% % idx = 0;
% %
% % for i = 1:length(nodes)
% %     if distances(nodes(i).id) < minDist
% %         minDist = distances(nodes(i).id);
% %         node = nodes(i);
% %         idx = i;
% %     end
% % end
% %
% % if idx > 0
% %     remainingNodes = [nodes(1:idx-1) nodes(idx+1:end)];
% % else
% %     remainingNodes = nodes;
% % end
% end