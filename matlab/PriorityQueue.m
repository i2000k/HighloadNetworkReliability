classdef PriorityQueue < handle
    properties (Access = private)
        heap
        indices
        size
    end
    
    methods
        function obj = PriorityQueue(maxSize)
            obj.heap = zeros(maxSize, 2); % [key, value]
            obj.indices = zeros(1, maxSize); % Позиции в куче
            obj.size = 0;
        end
        
        function insert(obj, nodeIdx, key)
            obj.size = obj.size + 1;
            obj.heap(obj.size, :) = [key, nodeIdx];
            obj.indices(nodeIdx) = obj.size;
            obj.bubbleUp(obj.size);
        end
        
        function [nodeIdx, key] = extractMin(obj)
            if obj.isEmpty()
                error('Queue is empty');
            end
            nodeIdx = obj.heap(1, 2);
            key = obj.heap(1, 1);
            obj.indices(nodeIdx) = 0;
            
            % Перемещаем последний элемент на вершину
            obj.heap(1, :) = obj.heap(obj.size, :);
            obj.indices(obj.heap(1, 2)) = 1;
            obj.size = obj.size - 1;
            
            if obj.size > 0
                obj.bubbleDown(1);
            end
        end
        
        function decreaseKey(obj, nodeIdx, newKey)
            pos = obj.indices(nodeIdx);
            if pos == 0 || obj.heap(pos, 1) <= newKey
                return;
            end
            obj.heap(pos, 1) = newKey;
            obj.bubbleUp(pos);
        end
        
        function contains = contains(obj, nodeIdx)
            contains = obj.indices(nodeIdx) ~= 0;
        end
        
        function empty = isEmpty(obj)
            empty = obj.size == 0;
        end
        
        function bubbleUp(obj, pos)
            while pos > 1
                parent = floor(pos / 2);
                if obj.heap(parent, 1) <= obj.heap(pos, 1)
                    break;
                end
                obj.swap(pos, parent);
                pos = parent;
            end
        end
        
        function bubbleDown(obj, pos)
            while 2 * pos <= obj.size
                child = 2 * pos;
                if child < obj.size && obj.heap(child + 1, 1) < obj.heap(child, 1)
                    child = child + 1;
                end
                if obj.heap(pos, 1) <= obj.heap(child, 1)
                    break;
                end
                obj.swap(pos, child);
                pos = child;
            end
        end
        
        function swap(obj, i, j)
            temp = obj.heap(i, :);
            obj.heap(i, :) = obj.heap(j, :);
            obj.heap(j, :) = temp;
            
            obj.indices(obj.heap(i, 2)) = i;
            obj.indices(obj.heap(j, 2)) = j;
        end
    end
end