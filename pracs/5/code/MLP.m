%Clean screen and variables
clear
clc
generar_g_p(1);
%%% User Inputs %%%
%Enter the inputs file
% inputs = dlmread(input('Ingresa el archivo de entradas: ', 's'));
inputs = dlmread('test_functions/g_p/inputs.txt');

%Enter the targets file
% targets = dlmread(input ('Ingresa el archivo de targets: ', 's'));
targets = dlmread('test_functions/g_p/targets.txt');

%Enter the signal range
% range = str2num(input ('Ingresa el rango de la señal: ', 's'));
range = [-2 2];

%Enter the MLP architecture (Max 3 hidden layers)
% arq = str2num(input('Ingresa el vector de  arq: ', 's'));
arq = [1 3 1];

%Enter the activation Function
% act_functions = str2num(input ('Ingresa el vector las get_activation_functiones de activacion, donde:\n1. Purelin    2. Logsig    3. Tansig\n', 's'));
act_functions = [2 1];

%Enter the learning factor
% alpha = input ('Ingresa el de factor de aprendizaje : ');
alpha = 0.01;
 
%Enter the the stopping conditions
% epochmax = input ('Ingresa el numero máximo de epocas: ');
epochmax = 1000;
% error_epoch_max = input ('Ingresa el valor mínimo del error de aprendizaje por época: ');
error_epoch_max = 0.000001;
% epoch_val = input ('Ingresa cuantas épocas se realizará una época de validación: ');
epoch_val = 500;
% num_val = input ('Ingresa el valor máximo de incrementos consecutivos en el error de validación: ');
num_val = 5;
% error_epoch_validation = input ('Ingresa el valor mínimo del error por época: ');

%%% Data set slicing %%%
% configuration = input ('Elija la configuración de distribución del dataset.\n 1. 80 - 10 - 10 \n 2. 70 - 15 - 15\n\n');
configuration = 1;
data_size = size(inputs, 2);
% Get the dataset slices
[training_ds, test_ds, validation_ds] = dataset_slices (configuration, inputs, targets);
training_size = size (training_ds, 1);
validation_size = size (validation_ds, 1);
test_size = size (test_ds, 1)

%%% Parameter calculation %%%
%Rows of the input vector
R = arq (1, 1);

%MLP layer calculation
num_layers = size (act_functions, 2);

%Preallocation of cells
W = cell (num_layers, 1);
b = cell (num_layers, 1);

%Number of files
num_weight_files = 0;
num_bias_files = 0;
for i = 1:num_layers
    for j = 1:(arq (i+1))
        for last_validation_error = 1:(arq (i))
            num_weight_files = num_weight_files + 1;
        end
    end
    num_bias_files = num_bias_files + 1;
end
%Preallocation for files
W_files = zeros (num_weight_files, 1);
b_files = zeros (num_bias_files, 1);

%Open weight files
current_file = 1;
for i = 1:num_layers
    path = strcat (pwd, '/Capa ', num2str(i), '/Pesos/');
    if ~exist (path, 'dir')
        mkdir (path);
    end
    for j = 1:(arq (i + 1))
        for k = 1:(arq (i))
            file = strcat (path, '/Pesos', num2str (j), '_', num2str (k), '.txt');
            W_files (current_file) = fopen (file, 'w');
            current_file = (current_file + 1);
        end
    end
end

%Open bias Files
current_file = 1;
for i = 1:num_layers
    path = strcat (pwd, '/Capa ', num2str(i), '/Bias/');
    if ~exist (path, 'dir')
        mkdir (path);
    end
    for j = 1:(arq (i + 1))
        file = strcat (path, '/Bias', num2str (j), '.txt');
        b_files (current_file) = fopen (file, 'w');
        current_file = (current_file + 1);
    end
end

%%% Data initialization %%%
flag = 0;
last_validation_error = 0;
final_validation_error = 0;
consecutive_increments = 0;

learning_error_plot = zeros (epochmax, 1);
validation_error_plot = zeros (ceil (epochmax / epoch_val), 1);
total_validation_epochs = 0;

%Initialize bias and weights from -1 to 1 randomly
Wi_file = 1;
bi_file = 1;
for i = 1:num_layers
    W {i} = -1 + 2 * rand (arq (i + 1), arq (i));
    b {i} = -1 + 2 * rand (arq (i + 1), 1);
    % Write it to the files
    for j = 1:(arq (i + 1))
        for k = 1:(arq (i))
            fprintf (W_files (Wi_file), '%.4f\r\n', W {i} (j, k));
            Wi_file = (Wi_file + 1);
        end
    end
    for j = 1:(arq (i + 1))
        fprintf (b_files (bi_file), '%.4f\r\n', b {i} (j, 1));
        bi_file = (bi_file + 1);
    end
end

% Preallocate for outputs, sensitivities and derivative of each layer
a = cell (num_layers + 1, 1);
S = cell (num_layers, 1);
F_m = cell (num_layers, 1);

%%% MLP larning algorithm %%%
for epoch = 1:epochmax
    % Reset values
    training_error = 0;
    bi_file = 1;
    Wi_file = 1;
    
    % Validate if this epoch is a validation epoch
    if mod (epoch, epoch_val) == 0
        total_validation_epochs = (total_validation_epochs + 1);
        current_validation_error = 0;
        % Data Propagation
        for data = 1:validation_size            
            a {1} = validation_ds (data, 1);
            for i = 1:num_layers
                a {i + 1} = get_activation_function (W {i, 1}, a {i, 1}, b {i, 1}, act_functions (1, i));
            end
            
            %Calculate the epoch validation error
            data_error = abs(validation_ds (data, 2) - a {num_layers + 1, 1});
            %Cumulative sum of each error
            current_validation_error = (current_validation_error + data_error);
        end
        current_validation_error = (current_validation_error / validation_size);
        
        validation_error_plot (epoch) = current_validation_error;
        
       % If the current error ys greater than the last
        if (current_validation_error > last_validation_error)
            consecutive_increments = consecutive_increments + 1;
            if consecutive_increments < num_val
                % Error update
                last_validation_error = current_validation_error;
                current_validation_error = 0;
            else
                fprintf ('No se obtuvo un aprendizaje correcto de la red\n');
                flag = 1;
                fprintf ('\nEarly Stopping en la iteración %d\n', epoch);
                break;
            end
        else
            last_validation_error = current_validation_error;
            consecutive_increments = 0;
        end
    else
        % This epoch isn't a validation one
        for data = 1:training_size
            % Data propagation
            a {1} = training_ds (data, 1);
            
            for i = 1:num_layers
                a {i + 1} = get_activation_function (W {i, 1}, a {i, 1}, b {i, 1}, act_functions (1, i))
            end
            
            % Calculate the validation error      
            data_error = (training_ds (data, 2) - a {num_layers + 1, 1});
            data_error = abs (data_error);
            % Cumulative sum of errors
            training_error = (training_error + data_error);
            training_error = (training_error / training_size);
            
            % Sensitivities calculation
            F_m {num_layers} = F_matrix (act_functions (1, num_layers), arq (1, num_layers + 1), a {num_layers + 1, 1});
            S {num_layers} = (-2 * F_m {num_layers} * data_error);
            
            % Back propagation algorithm
            for i = (num_layers - 1):-1:1
                F_m {i} = F_matrix (act_functions (1, i), arq (1, i + 1), a {i + 1, 1});
                S {i} = F_m {i, 1} * (W {i+1, 1})' * S {i + 1, 1};
            end
            
            % Weight and bias update
            for i = num_layers:-1:1
                W {i, 1} = (W {i, 1} - (alpha * S {i, 1} * (a {i, 1})'));
                b {i, 1} = (b {i, 1} - (alpha * S {i, 1}));
            end
        end
        final_validation_error = training_error;
        
        learning_error_plot (epoch) = training_error;
    end
    
    %Plot the values
    Wi_file = 1;
    bi_file = 1;
    for k = num_layers:-1:1
        for j = 1:(arq (k + 1))
            for last_validation_error = 1:(arq (k))
                fprintf (W_files (Wi_file), '%.4f\r\n', W {k}(j, last_validation_error));
                Wi_file = (Wi_file + 1);
            end
        end
        for j = 1:(arq (k + 1))
            fprintf (b_files (bi_file), '%.4f\r\n', b {k}(j, 1));
            bi_file = (bi_file + 1);
        end
    end
    
    % Stopping conditions
    if training_error < error_epoch_max && training_error > 0
        fprintf ('Se obtuvo un aprendizaje exitoso en la epoch: %d\n', epoch);
        break;
    end
end

if flag == 1
    Wi_file = 1;
    bi_file = 1;
    for k = num_layers:-1:1
        for j = 1:(arq (k + 1))
            for last_validation_error = 1:(arq (k))
                fprintf (W_files (Wi_file), '%.4f\r\n', W {k}(j, last_validation_error));
                Wi_file = (Wi_file + 1);
            end
        end
        for j = 1:(arq (k + 1))
            fprintf (b_files (bi_file), '%.4f\r\n', b {k}(j, 1));
            bi_file = (bi_file + 1);
        end
    end
end

%%% Close files %%%
for i = 1:num_weight_files
    fclose (W_files (i));
end

for i = 1:num_bias_files
    fclose (b_files (i));
end

%%% Test Dataset propagation %%%
error_test_ds = 0;
output = ones (test_size, 1);
for i = 1:test_size
    a {1} = test_ds (i, 1);
    for k = 1:num_layers
        a {k + 1} = get_activation_function (W {k, 1}, a {k, 1}, b {k, 1}, act_functions (1, k));
    end
    aux = (test_ds (i, 2) - a {num_layers + 1, 1});
    aux = abs (aux);
    error_test_ds = error_test_ds + (aux / test_size);
    output (i) = a {num_layers + 1, 1};
end

% Final plot of the errors
fprintf ('Error final de aprendizaje = %.4f\n', final_validation_error);
fprintf ('Error final de validation_ds = %.4f\n', last_validation_error);
fprintf ('Error final de test_ds = %.4f\n', error_test_ds);

%%% PLoting %%%
test_ds_Errores = figure ('Name', 'Errores de aprendizaje y validación');
figure (test_ds_Errores);
grid on;
rango = 1:1:epoch;
rango_aux = epoch_val:epoch_val:(epoch_val * total_validation_epochs);
% Verde oscuro
contorno_validation_ds = [0 0.4980 0];
% Verde claro
relleno_validation_ds = [0 1 0];
scatter (rango_aux, validation_error_plot (epoch_val:epoch_val:total_validation_epochs*epoch_val,1), 'MarkerEdgeColor',contorno_validation_ds, 'MarkerFaceColor', relleno_validation_ds, 'LineWidth',1.5);
hold on;
% Azul oscuro
contorno_aprendizaje = [0.0784 0.1686 0.5490];
% Azul claro
relleno_aprendizaje = [0 0.7490 0.7490];
scatter (rango, learning_error_plot (1:epoch,1), 'MarkerEdgeColor',contorno_aprendizaje, 'MarkerFaceColor', relleno_aprendizaje, 'LineWidth',1.5);
title ('Errores de aprendizaje y validation_ds');
xlabel ('epoch');
ylabel ('Valor del error');
legend ('Error validation_ds', 'Error aprendizaje');

% CONJUNTO DE test_ds CON TARGET
test_ds_Graph = figure ('Name', 'Conjunto de test_ds');
figure (test_ds_Graph);
grid on;
rango = test_ds (:, 1);
% Verde oscuro
contorno_salida = [0 0.4980 0];
% Verde claro
relleno_salida = [0 1 0];
scatter (rango, output, 'MarkerEdgeColor',contorno_salida, 'MarkerFaceColor', relleno_salida, 'LineWidth',1.5);
hold on;
% Azul oscuro
contorno_target = [0.0784 0.1686 0.5490];
% Azul claro
relleno_target = [0 0.7490 0.7490];
scatter (rango, test_ds (:, 2), 'MarkerEdgeColor',contorno_target, 'MarkerFaceColor', relleno_target, 'LineWidth',1.5);
title ('Conjunto de test_ds');
xlabel ('p');
ylabel ('f (p)');
legend ('Salida del MLP', 'Target');

% PESOS
Pesos_Graph = figure ('Name', 'Evolución de los pesos');
grid on;
for i = 1:num_layers
    figure (Pesos_Graph);
    path = strcat (pwd, '/Capa ', num2str(i), '/Pesos/');
    for j = 1:(arq (i + 1))
        for k = 1:(arq (i))
            file = strcat (path, '/Pesos', num2str (j), '_', num2str (k), '.txt');
            simb = strcat('W(',num2str(j),',',num2str(k),')');
            evolucion_pesos = importdata(file);
            plot(evolucion_pesos','DisplayName',simb);
            hold on;
        end
    end
    titulo = strcat('Pesos - capa',{' '},num2str(i));
    title(titulo);
    ylabel('W');
    xlabel('epoch');
    hold off
end

% % BIAS
% rango = 0:1:epoch;
% Bias_Graph = figure ('Name', 'Evolución de los bias');
% grid on
% for i = 1:num_layers
%     figure (Bias_Graph);
%     path = strcat (pwd, '/Capa ', num2str(i), '/Bias/');
%     for j = 1:(arq (i+1))
%         archivo_bias = strcat (path, '/Bias', num2str (j), '.txt');
%         simb = strcat('b(',num2str(j),')');
%         evolucion_bias = importdata (archivo_bias); % Identificador para la grafica
%         plot(rango, evolucion_bias','DisplayName', simb);
%         hold on
%     end
%     titulo = strcat('Bias - capa',{' '},num2str(i));
%     title(titulo);
%     ylabel('b');
%     xlabel('epoch');
%     hold off
% end

figure
rango = training_ds(:,1);
% Verde oscuro
contorno_salida = [0 0.4980 0];
% Verde claro
relleno_salida = [0 1 0];
plot(output,'MarkerEdgeColor',contorno_salida, 'MarkerFaceColor', relleno_salida, 'LineWidth',1.5);
grid on
hold on
% Azul oscuro
contorno_target = [0.0784 0.1686 0.5490];
% Azul claro
relleno_target = [0 0.7490 0.7490];
plot(training_ds(:,2),'MarkerEdgeColor',contorno_target, 'MarkerFaceColor', relleno_target, 'LineWidth',1.5);
title('Conjunto de training_ds');
ylabel('f(p)');
xlabel('p');
legend('Salida del MLP','Targets');
hold off

