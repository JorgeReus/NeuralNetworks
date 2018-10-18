inputs = importdata('inputs.txt');
targets = importdata('targets.txt');
max_it = 100;
% merged the matrixes
total_matrix = [ inputs targets];
max_random_range = 1;
min_random_range = -1;
% Weight and bias initialization
W = rand(1, size(inputs, 2))*(2*max_random_range) + min_random_range
b = rand
Wevo = [];
bevo = [];
% For plotting the evolution of the parameters
Wevo = [Wevo; W];
bevo = [bevo; b];
mode = input('Elija un modo: 1->Gráfico, 2->Regla de Aprendizaje\n', 's');
if(mode=='1')
    if (size(inputs, 2) == 2)
        num_tries = 10;
        for i = 1:num_tries
            W = rand(1, size(inputs, 2))*(2*max_random_range) + min_random_range
            b = rand
            convergence_counter = 0;
            for row = total_matrix.'
                p = row(1:size(inputs, 2));
                target = row(size(inputs, 2) + 1);
                a = hardlim(W*p + b);
                e = target - a;
                if (e == 0)
                    convergence_counter = convergence_counter + 1;
                end
            end
            if(convergence_counter == size(total_matrix, 1))
                fprintf("Convergió en %d iteraciones\n", i);
                break;
            end
        end
        plotPerceptron(total_matrix, W, b);
    else
        fprintf("Solo impresiones en 2 dimensiones soportada");
    end   
elseif(mode=='2')
    % For convergence checking
    Waux = W;
    baux = b;
    % Begin the iterations
    for i = 1:max_it
        convergence_counter = 0;
        for row = total_matrix.'
            % Array Indexing
            p = row(1:size(inputs, 2));
            target = row(size(inputs, 2) + 1);
            a = hardlim(W*p + b);
            % Calculate the error
            e = target - a;
            if (e == 0)
                convergence_counter = convergence_counter + 1;
            end
            % Convergence Checking
            Waux = W;
            baux = b;
            % Weight update
            W = W + e*p';
            % Bias update
            b = b + e;
            % Save the values
            Wevo = [Wevo; W];
            bevo = [bevo; b];
        end
        if(convergence_counter == size(total_matrix, 1))
            break;
        end
    end
    W
    b
    plotHistory(Wevo, bevo);
    if (size(inputs, 2) == 2)
        plotPerceptron(total_matrix, W, b);
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

function h = plotPerceptron(matrix, W, b)
    % Plot the perceptron desicion boundary and the inputs
    figure
    ax = gca;                        % gets the current axes
    ax.XAxisLocation = 'origin';     % sets t1hem to zero
    ax.YAxisLocation = 'origin'; 
    hold on
    grid on
    % plot the desicion boundary
    x = -10:10;
    slope = -(b / W(2)) / (b / W(1));
    intercept = -b / W(2);
    y = slope * x + intercept; 
    plot(x, y);
    ylim([-10 10])
    xlim([-10 10])
    r = 5;
    for row = matrix.'
        p = row(1:size(matrix, 2));
        target = row(size(matrix, 2));
        % Plot the input
        if (target == 1)
            h = circle(p(1), p(2), r, 'black');
        else
            h = circle(p(1), p(2), r, 'white');
        end
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