clc
clear

% Read the inputs file
inputs_path = strcat(input('Ingrese el nombre del archivo de inputs sin la extensión: ','s'), '.txt');
%inputs_path = 'inputs.txt';
inputs = importdata(inputs_path);

% Read the targets
targets_path = strcat(input('Ingrese el nombre del archivo de targets sin la extensión: ','s'), '.txt');
%targets_path = 'targets.txt';
targets = importdata(targets_path);

data_size = size(inputs, 1);

% Enter MLP architecture
architecture = str2num(input('Ingrese el vector de la arquitectura: ','s'));
% Calculate layer parameters
%architecture = str2num('1 16 10 1');
num_layers = length(architecture) - 1;
R = architecture(1);
functions_vector = str2num(input('Ingrese el vector de las funciones de activación: 1) purelin()\n2) logsig()\n3) tansig()\n\n: ','s'));
%functions_vector = str2num('3 2 1');

% Enter the learning factor
alpha = input('Ingresa el valor del factor de aprendizaje(alpha): ');
%alpha = .01;

epochmax = input('Ingresa el número máximo de épocas: ');
% epochmax = 10000;
%validation_iter = 500;
%numval = 7;
%error_epoch_validation = .0000000000000001;
numval = input('Numero maximo de incrementos consecutivos del error de validacion (numval): ');
error_epoch_validation = input('Ingrese el valor minimo del error de epoca (error_epoch_validation): ');
validation_iter = input('Ingrese el múltiplo de épocas para realizar una época de validación  (validation_iter): ');

% Dataset Slicing
config_option = input('Elija una configuración de distribución de datasets: \n1: 80-10-10\n2: 70-15-15\n');
%config_option = 2;
[training_ds, test_ds, validation_ds] = dataset_slices(config_option, inputs, targets);
validation_ds_size = size(validation_ds, 1);
test_ds_size = size(test_ds, 1);
training_ds_size = size(training_ds, 1);

disp('Dataset de entrenamiento:');
disp(training_ds);
disp('Dataset de validacion:');
disp(validation_ds);
disp('Dataset de prueba:');
disp(test_ds);

% Open the files for weights and bias
total_weight_files = 0;
total_bias_files = 0;
for i=1:num_layers
    % For neurons
    for j=1:architecture(i + 1)
        % For weights
        for l=1:architecture(i)
            total_weight_files = total_weight_files + 1;
        end
    end
    total_bias_files = total_bias_files + 1;
end

W_files = zeros(total_weight_files, 1);
b_files = zeros(total_bias_files, 1);

current_file = 1;
for i=1:num_layers
    path = strcat(pwd, '/historico/capa_', num2str(i), '/pesos/');
    if ~exist(path, 'dir')
        mkdir(path);
    end
    % For layers
    for j=1:architecture(i + 1)
        % For neurons
        for k=1:architecture(i)
            archivo_pesos = strcat(path, '/pesos', num2str(j), '_', num2str(k),'.txt');
            W_files(current_file) = fopen(archivo_pesos,'w');
            current_file = current_file +1;
        end
    end
end

current_file = 1;
for i=1:num_layers
    path = strcat(pwd,'/historico/capa_', num2str(i), '/bias/');
    if ~exist(path, 'dir')
        mkdir(path);
    end
    for j=1:architecture(i+1)
        archivo_bias = strcat(path,'/bias',num2str(j),'.txt');
        b_files(current_file) = fopen(archivo_bias,'w');
        current_file = current_file +1;
    end
end

% Initialize MLP parameters and Print them

num_w_files = 1;
num_b_files = 1;
W = cell(num_layers,1);
b = cell(num_layers,1);
% Output of each layer
a = cell(num_layers + 1, 1);
% Sentitivities
S = cell(num_layers, 1);
% Derivatives of each layer
F_m = cell(num_layers, 1);

% For each layer
for i=1:num_layers
    % Random value
    W_r_value = 2 * rand(architecture(i + 1), architecture(i)) - 1;
    b_r_value = 2* rand(architecture(i + 1), 1) - i;
    W{i} = W_r_value
    b{i} = b_r_value
    % For each neuron
    for j=1:architecture(i + 1)
        %For each weight
        for k=1:architecture(i)
            % Print wights value
            fprintf(W_files(num_w_files), '%f\r\n', W_r_value(j, k));
            num_w_files = num_w_files + 1;
        end
    end
    % For each neuron
    for j=1:architecture(i + 1)
        % print bias value
        fprintf(b_files(num_b_files), '%f\r\n', b_r_value(j));
        num_b_files = num_b_files + 1;
    end
end

% Learning algorithm
num_validation_epoch = 0;
early_stopping_increment = 0;
validation_error = 0;
learning_error = 0;
early_s_counter = 0;

% initialize vectors for printing errors
learning_err_values = zeros(epochmax, 1);
evaluation_err_values = zeros(ceil(epochmax / validation_iter), 1);
for epoch=1:epochmax
    l_error = 0;
    % Reset the values
    num_w_files = 1;
    num_b_files = 1;
    % if isn't a validation epoch
    if(mod(epoch ,validation_iter) ~= 0)
        for t_data=1:training_ds_size    
            % initial condition
            a{1} = training_ds(t_data, 1); 
            % Foward propagation
            for t_p=1:num_layers
                W_aux = cell2mat(W(t_p));
                b_aux = cell2mat(b(t_p));
                a_aux = cell2mat(a(t_p));
                n_f = W_aux * a_aux + b_aux;
                a{t_p + 1} = get_activation_function(n_f, functions_vector(t_p));
            end
            a_aux = cell2mat(a(num_layers + 1));
            t_error = training_ds(t_data, 2) - a_aux;
            l_error = l_error + (t_error / data_size);
            % Sensitivities calculation
            F_m{num_layers} = get_F_matrix(functions_vector(num_layers), architecture(num_layers + 1), a_aux);
            F_m_temp = cell2mat(F_m(num_layers));
            S{num_layers} = F_m_temp * (t_error)*(-2);
            % Backpropagation
            for m = num_layers-1:-1:1
                W_aux = cell2mat(W(m+1));
                s_aux = cell2mat(S(m+1));
                a_aux = cell2mat(a(m+1));
                F_m{m} = get_F_matrix(functions_vector(m),architecture(m+1),a_aux);
                F_m_temp = cell2mat(F_m(m));
                S{m} = F_m_temp * (W_aux')*s_aux;
            end
            % Learning Rules
            for k = num_layers:-1:1
                W_aux = cell2mat(W(k));
                b_aux = cell2mat(b(k));
                s_aux = cell2mat(S(k));
                a_aux = cell2mat(a(k));
                W{k} = W_aux - (alpha * s_aux * a_aux');
                b{k} = b_aux - (alpha * s_aux);
                W_aux = cell2mat(W(k));
                b_aux = cell2mat(b(k));
            end
        end
        learning_error = l_error;
        learning_err_values(epoch) = l_error;      
    % This epoch is a validation one
    else
        val_error = 0;
        num_validation_epoch = num_validation_epoch + 1;
        for t_data = 1:validation_ds_size
            % Initial Condition
            a{1} = validation_ds(t_data, 1);
            % Foward propagation
            for k=1:num_layers
                W_aux = cell2mat(W(k));
                a_aux = cell2mat(a(k));
                b_aux = cell2mat(b(k));
                n_f = W_aux * a_aux + b_aux;
                a{k + 1} = get_activation_function(n_f, functions_vector(k));
            end
            a_aux = cell2mat(a(num_layers+1));
            val_error = validation_ds(t_data,2)-a_aux;
            val_error = val_error+(val_error/validation_ds_size);
        end
        evaluation_err_values(epoch) = val_error;
        if early_stopping_increment == 0
            validation_error = val_error;
            early_stopping_increment = early_stopping_increment+1;
            fprintf('Incremento actual para early stopping = %d\n', early_stopping_increment);
        else
            if val_error > validation_error
                validation_error = val_error;
                early_stopping_increment = early_stopping_increment+1;
                fprintf('Incremento actual para early stopping = %d\n', early_stopping_increment);
                if early_stopping_increment == numval
                    % Reset the counter
                    early_s_counter = 1;
                    fprintf('Early stopping en la época:  %d\n', epoch);
                    break;
                end
            else
                validation_error = 0;
                early_stopping_increment = 0;
                fprintf('Incremento actual para early stopping = %d\n', early_stopping_increment);
            end
        end
    end
  
    % Print the values on console
    num_w_files = 1;
    num_b_files = 1;
    for k = num_layers:-1:1
        W_aux = cell2mat(W(k));
        b_aux = cell2mat(b(k));
        for j=1:architecture(k+1)
            for l=1:architecture(k)
                fprintf(W_files(num_w_files), '%f\r\n', W_aux(j,l));
                num_w_files = num_w_files +1;
            end
        end
        for j=1:architecture(k + 1)
            fprintf(b_files(num_b_files), '%f\r\n', b_aux(j));
            num_b_files = num_b_files + 1;
        end
    end
    
    % Check stopping calculations
    if mod(epoch,validation_iter) ~= 0 && l_error <= error_epoch_validation && l_error >= 0
        learning_error = l_error;
        fprintf('Aprendizaje exitoso en la época %d\n', epoch);
        break;
    end
end

if epoch == epochmax
    disp('Se llego a epochmax');
end

% Print the las final values 
if early_s_counter == 1
    num_w_files = 1;
    num_b_files = 1;
    for k = num_layers:-1:1
        W_aux = cell2mat(W(k));
        b_aux = cell2mat(b(k));
        for j = 1:architecture(k + 1)
            for l=1:architecture(k)
                fprintf(W_files(num_w_files), '%f\r\n', W_aux(j, l));
                num_w_files = num_w_files + 1;
            end
        end
        for j=1:architecture(k + 1)
            fprintf(b_files(num_b_files), '%f\r\n', b_aux(j));
            num_b_files = num_b_files + 1;
        end
    end
end

% Close all files
for i=1:total_weight_files
    fclose(W_files(i));
end
for i=1:total_bias_files
    fclose(b_files(i));
end

% Propagate the test dataset
test_error = 0;
output = zeros(test_ds_size,1);
for i=1:test_ds_size
    % Initial condition
    a{1} = test_ds(i,1);
    for k=1:num_layers
        W_aux = cell2mat(W(k));
        a_aux = cell2mat(a(k));
        b_aux = cell2mat(b(k));
        n_f = W_aux*a_aux+b_aux;
        a{k+1} = get_activation_function(n_f, functions_vector(k));
    end
    test_data = cell2mat(a(1));
    a_aux = cell2mat(a(num_layers + 1));
    test_error = test_error + (1 / test_ds_size) * (test_ds(i,2) - a_aux);
    output(i) = a_aux;
end

% Print last errors
fprintf('Error de aprendizaje = %f\n', learning_error);
fprintf('Error de validación = %f\n', validation_error);
fprintf('Error de prueba = %f\n', test_error);


% Output vs test
scatter_output_vs_test(test_ds, output);
% Propagate the training size for ploting

output = zeros(training_ds_size,1);
for i=1:training_ds_size
    % Initial Condition
    a{1} = training_ds(i, 1);
    for k=1:num_layers
        W_aux = cell2mat(W(k));
        a_aux = cell2mat(a(k));
        b_aux = cell2mat(b(k));
        a{k+1} = get_activation_function(W_aux*a_aux+b_aux,functions_vector(k));
    end
    a_aux = cell2mat(a(num_layers + 1));
    test_error = test_error + (1 / training_ds_size) * (training_ds(i,2) - a_aux);
    output(i) = a_aux;
end

scatter_output_vs_training(training_ds, output);

% Plot the error evolution
error_plot(validation_iter, num_validation_epoch, learning_err_values, epoch, evaluation_err_values);
% Plot weight evolution
weight_evolution_plot(architecture, num_layers, epoch);
% Plot bias evolution
bias_evolution_plot(architecture, num_layers, epoch);

% Write final values
for i=1:num_layers
    path = strcat(pwd, '/Valores_finales/capa_', num2str(i), '/');
    if ~exist(path, 'dir')
        mkdir(path);
    end
    W_aux = cell2mat(W(i));
    res_pesos = strcat(path, '/pesos.txt');
    dlmwrite(res_pesos, W_aux, ';');
end

for i=1:num_layers
    path = strcat(pwd,'/Valores_finales/capa_', num2str(i), '/');
    if ~exist(path, 'dir')
        mkdir(path);
    end
    b_aux = cell2mat(b(i));
    res_bias = strcat(path, '/bias.txt');
    dlmwrite(res_bias, b_aux, ';');
end


