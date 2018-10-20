%epoch_max = input('Ingrese epochmax: ');
%e_epoch = input('Ingrese E epoch: ');
 %alpha = input('Ingrese el factor de aprendizaje: ');
 
epoch_max = 50;
e_epoch = .01;
alpha = .180;
inputs = importdata('inputs.txt');
targets = importdata('targets.txt');
max_it = epoch_max;
% merged the matrixes
total_matrix = [ inputs targets];
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
%mode = input('Elija un modo: 1->Gr�fico, 2->Regla de Aprendizaje\n', 's');
mode = '2';
if(mode=='1')
    if (size(inputs, 2) == 2)
        num_tries = 10;
        for i = 1:num_tries
            W = rand(size(targets, 2), size(inputs, 2))*(2*max_random_range) + min_random_range
            b = rand(size(targets, 2), 1) * (2*max_random_range) + min_random_range
            convergence_counter = 0;
            for row = total_matrix.'
                p = row(1:size(inputs, 2));
                target = row(size(inputs, 2) + 1);
                a = W*p + b;
                e = target - a;
                if (e == 0)
                    convergence_counter = convergence_counter + 1;
                end
            end
            if(convergence_counter == size(total_matrix, 1))
                fprintf("Convergi� en %d iteraciones\n", i);
                break;
            end
        end
        plotPerceptron(total_matrix, W, b);
    else
        fprintf("Solo impresiones en 2 dimensiones soportada");
    end   
elseif(mode=='2')
    Waux = W;
    baux = b;
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
            % Convergence Checking
            Waux = W;
            baux = b;
            % Weight update
            W = W + 2*alpha*e*p';
            % Bias update
            b = 2*alpha*e;
            % Save the values
            Wevo = [Wevo; W];
            bevo = [bevo; b];
            Eepoch_values = [Eepoch_values; e];
        end
        Eepoch = sum(Eepoch_values)/ size(total_matrix, 1);
        if(Eepoch == 0 || Eepoch < e_epoch)
            fprintf("La red convergi�");
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
    fprintf("Opci�n no reconocida\n");
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
    title('Evoluci�n de Par�metros');
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
    xlabel('�pocas') 
    ylabel('Valor') 
    hold off
end