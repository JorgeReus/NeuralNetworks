mode = input('Elija un modo: 1->Sin bias, 2->Con bias\n', 's');
epoch_max = input('Ingrese epochmax: ');
e_epoch = input('Ingrese E epoch: ');
alpha = input('Ingrese el factor de aprendizaje: ');
inputs = importdata('inputs.txt');
targets = importdata('targets.txt');
max_it = epoch_max;
% merged the matrixes
total_matrix = [inputs targets];
max_random_range = 1;
min_random_range = -1;
% Weight and bias initialization
W = rand(size(targets, 2), size(inputs, 2))*(2*max_random_range) + min_random_range
b = rand(size(targets, 2), 1) * (2*max_random_range) + min_random_range
Wevo = [];
bevo = [];
% For plotting the evolution of the parameters
Wevo = [Wevo; W];
bevo = [bevo; b];
if(mode=='1')
    r_value = randi([3 7],1,1);
    total_matrix = logicalModel(r_value)
    Wevo = [];
    W = rand(1, r_value)*(2*max_random_range) + min_random_range;
    Wevo = [Wevo; W];
    for i = 1:max_it
        Eepoch_values = [];
        for row = total_matrix.'
            % Array Indexing
            p = row(1:r_value);
            target = row(r_value + 1: end);
            a = purelin(W*p);
            % Calculate the error
            e = (target - a);
            % Convergence Checking
            Waux = W;
            baux = b;
            % Weight update
            W = W + 2*alpha*e*p';
            % Save the values
            Wevo = [Wevo; W];
            Eepoch_values = [Eepoch_values; e];
        end
        Eepoch = abs(sum(Eepoch_values)/ size(total_matrix, 1));
        if(Eepoch == 0 || Eepoch < e_epoch)
            fprintf("La red convergió");       
            break;
        end
    end
    W
    plotHistoryNoBias(Wevo);
    dlmwrite('parametrosFinales.txt','Pesos', 'delimiter', '');
    dlmwrite('parametrosFinales.txt',W,'delimiter',' ', '-append');
elseif(mode=='2')
    % Begin the iterations
    for i = 1:max_it
        Eepoch_values = [];
        for row = total_matrix.'
            % Array Indexing
            p = row(1:size(inputs, 2));
            target = row(size(inputs, 2) + 1: end);
            a = purelin(W*p + b);
            % Calculate the error
            e = (target - a);
            % Weight update
            W = W + 2*alpha*e*p';
            % Bias update                       
            b = b + 2*alpha*e;
            % Save the values
            Wevo = [Wevo; W];
            bevo = [bevo; b];
            Eepoch_values = [Eepoch_values; e'];
        end
        Eepoch = abs(sum(Eepoch_values) / size(Eepoch_values, 1));
        if(all(Eepoch == 0) || all(Eepoch < e_epoch))
            fprintf("La red convergió\n");
            break;
        end
    end
    W
    b
    dlmwrite('parametrosFinales.txt','Pesos', 'delimiter', '');
    dlmwrite('parametrosFinales.txt',W,'delimiter',' ', '-append');
    dlmwrite('parametrosFinales.txt','Bias', '-append',  'roffset', 1, 'delimiter', '');
    dlmwrite('parametrosFinales.txt',b,'-append', 'delimiter', ' ');
    plotHistory(Wevo, bevo);
    if (size(inputs, 2) == 2)
       plotAdaline(total_matrix, W, b);
    else
        fprintf("Solo impresiones en 2 dimensiones soportada");
    end
else
    fprintf("Opción no reconocida\n");
end
    
function h = circle(x ,y, r, color)
    hold on
    h = plot(x, y, '-o', ...
        'MarkerSize', r, ...
        'MarkerEdgeColor', 'black',...
        'Color', color, ...
        'MarkerFaceColor', color);
    hold off
end

function h = plotAdaline(matrix, W, b)
    % Plot the perceptron desicion boundary and the inputs
    figure
    ax = gca;                        % gets the current axes
    ax.XAxisLocation = 'origin';     % sets t1hem to zero
    ax.YAxisLocation = 'origin'; 
    hold on
    grid on
    % plot the desicion boundary
    x = -10:10;
    for i=1:size(W, 1)
        slope = -(b(i) / W(i, 2)) / (b(i) / W(i, 1));
        intercept = -b(i) / W(i, 2);
        y = slope * x + intercept; 
        plot(x, y); 
    end
    ylim([-10 10])
    xlim([-10 10])
    r = 5;
    colors = 'ymcrgbwk';
    i = 1;
    M = containers.Map('KeyType','char','ValueType','char');
    for row = matrix.'
        target = row(size(W, 2) + 1:end);
        M(mat2str(target)) = colors(i);
        i = i + 1;
    end
    for row = matrix.'
        p = row(1:size(W, 2));
        target = row(size(W, 2) + 1:end);
        h = circle(p(1), p(2), r, M(mat2str(target)));
    end
    hold off
end

function plotHistory(Wevo, bevo)
    % Plot the values
    hold on
    grid on
    title('Evolución de Parámetros');
    legends = [];
    x = 1:size(Wevo, 1);
    for i = 1:size(Wevo, 2)
        colW = Wevo(:, i);
        plot(x, colW);
        legends = [legends, sprintf("w%d", i)];
    end
    plot(x, bevo);
    legends = [legends, "bias"];
    legends = mat2cell(legends,1, ones(1,numel(legends)));
    legend(legends{:});
    xlabel('Épocas') 
    ylabel('Valor') 
    hold off
end

function plotHistoryNoBias(Wevo)
    % Plot the values
    hold on
    grid on
    title('Evolución de Parámetros');
    legends = [];
    x = 1:size(Wevo, 1);
    for i = 1:size(Wevo, 2)
        colW = Wevo(:, i);
        plot(x, colW);
        legends = [legends, sprintf("w%d", i)];
    end
    legends = mat2cell(legends,1, ones(1,numel(legends)));
    legend(legends{:});
    xlabel('Épocas') 
    ylabel('Valor') 
    hold off
end

function [table] = logicalModel(i)
    % logicalModel(I, gate) returns a matrix representing a truth table and
    % the last column represents the oupot base on all the previous columns
    % based on the (gate) parameter
    % INPUT: (I) shall be an integer >= 1
    % INPUT: (gate) shall be 'and' or 'or'
    % OUTPUT: logicalModel is a binary matrix of size [2^I,I + 1]
    % Heavily inspired in Paul Metcalf's CONDVECTS
    % Acknowledgements: Paul Metcalf
    
    g = 2;
    i2 = 2^i;
    table = false(i2,i + 1);
    for m = 1 : 1 : i
        m2 = 2^m;
        m3 = (m2/2)-1;
        i3 = i-m+1;
        for g = g : m2 : i2
            for k = 0 : 1 : m3
                table(g+k,i3) = true;
            end
        end
        g = m2+1;
    end
    table = table * 1;
    for row_index = 1:size(table, 1)
      row = table(row_index,:);
      res = row(1);     
      table(row_index, end) = row_index - 1; 
    end  
end