clc
clear

% Read the inputs file
% inputs_path = strcat(input('Ingrese el nombre del archivo de inputs sin la extensi�n: ','s'), '.txt');
inputs_path = 'inputs.txt';
inputs = importdata(inputs_path);

% Read the targets
%targets_file = strcat(input('Ingrese el nombre del archivo de targets sin la extensi�n: ','s'), '.txt');
targets_path = 'targets.txt';
targets = importdata(targets_path);

data_size = size(inputs, 1);

% Enter MLP architecture
% architecture = str2num(input('Ingrese el vector de la arquitectura: ','s'));
% Calculate layer parameters
architecture = str2num('1 3 1');
num_layers = length(architecture) - 1;
R = architecture(1);
% fun_capa = str2num(input('Ingrese el vector de las funciones de activaci�n: 1) purelin()\n2) logsig()\n3) tansig()\n\n: ','s'));
fun_capa = str2num('2 1');

% Enter the learning factor
% alpha = input('Ingresa el valor del factor de aprendizaje(alpha): ');
alpha = .0703;

% epochmax = input('Ingresa el n�mero m�ximo de �pocas: ');
epochmax = 2000;
validation_iter = 20;
numval = 7;
error_epoch_validation = .000000000000001;
% numval = input('Numero maximo de incrementos consecutivos del error de validacion (numval): ');
% error_epoch_validation = input('Ingrese el valor minimo del error de epoca (error_epoch_validation): ');
% validation_iter = input('Ingrese el m�ltiplo de �pocas para realizar una �poca de validaci�n  (validation_iter): ');

% Dataset Slicing
% config_option = input('Elija una configuraci�n de distribuci�n de datasets: \n1: 80-10-10\n2: 70-15-15\n');
config_option = 2;
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

% Initialize MLP parameters

num_archivos_pesos = 1;
num_archivos_bias = 1;
W = cell(num_layers,1);
b = cell(num_layers,1);
disp('Valores iniciales de las matrices:');
for i=1:num_layers
    temp_W = -1 + 2*rand(architecture(i+1),architecture(i));
    W{i} = temp_W;
    fprintf('W_%d = \n',i);
    disp(W{i});
    temp_b = -1 + (2)*rand(architecture(i+1),1);
    b{i} = temp_b;
    fprintf('b_%d = \n',i);
    disp(b{i});
    
    % Se imprimen los valores iniciales en los archivos
    for j=1:architecture(i+1)
        for k=1:architecture(i)
            fprintf(W_files(num_archivos_pesos),'%f\r\n',temp_W(j,k));
            num_archivos_pesos = num_archivos_pesos +1;
        end
    end
    for j=1:architecture(i+1)
        fprintf(b_files(num_archivos_bias),'%f\r\n',temp_b(j));
        num_archivos_bias = num_archivos_bias + 1;
    end
    
end

% Se utiliza una cell para guardar las salidas de cada capa
a = cell(num_layers+1,1);

% Se utiliza una cell para guardas las sensitividades de cada capa y las
% matrices de derivadas.
S = cell(num_layers,1);
F_m = cell(num_layers,1);
X = input('Presiona ENTER para comenzar el aprendizaje...');

% Comienza el aprendizaje
early_stopping = 0;
Err_val = 0;
Err_ap = 0;
valores_graficacion_eap = zeros(epochmax,1);
valores_graficacion_eval = zeros(ceil(epochmax/validation_iter),1);
count_val = 0;
num_it_val = 0; % Numero de iteraciones de validacion realizadas
for it=1:epochmax
    num_archivos_pesos = 1;
    num_archivos_bias = 1;
    Eap = 0; % Error de aprendizaje
    % Si no es una iteracion de validacion
    if(mod(it,validation_iter)~=0)
        for dato=1:training_ds_size
            
            a{1} = training_ds(dato,1); % Condicion inicial
            
            % Se propaga hacia adelante el elemento del cto. de
            % entrenamiento
            for k=1:num_layers
                W_temp = cell2mat(W(k));
                a_temp = cell2mat(a(k));
                b_temp = cell2mat(b(k));
                a{k+1} = funcionDeActivacion(W_temp*a_temp+b_temp,fun_capa(k));
            end
            a_temp = cell2mat(a(num_layers+1));
            ej = training_ds(dato,2)-a_temp;
            Eap = Eap+(ej/data_size);
            
            % Se calculan las sensitividades y se propagan hacia atras,
            % es decir, inicia el backpropagation.
            F_m{num_layers} = obtenerF(fun_capa(num_layers),architecture(num_layers+1),a_temp);
            F_m_temp = cell2mat(F_m(num_layers));
            S{num_layers} = -2*F_m_temp*(ej);
            for m = num_layers-1:-1:1
                W_temp = cell2mat(W(m+1));
                a_temp = cell2mat(a(m+1));
                S_temp = cell2mat(S(m+1));
                F_m{m} = obtenerF(fun_capa(m),architecture(m+1),a_temp);
                F_m_temp = cell2mat(F_m(m));
                S{m} = F_m_temp*(W_temp')*S_temp;
            end
            
            % Se aplican las reglas de aprendizaje
            for k=num_layers:-1:1
                W_temp = cell2mat(W(k));
                b_temp = cell2mat(b(k));
                a_temp = cell2mat(a(k));
                S_temp = cell2mat(S(k));
                W{k} = W_temp-(alpha*S_temp*(a_temp'));
                b{k} = b_temp-(alpha*S_temp);
                W_temp = cell2mat(W(k));
                b_temp = cell2mat(b(k));
            end
            
        end
        Err_ap = Eap;
        
        % Se guarda el valor de graficación de Eap
        valores_graficacion_eap(it) = Eap;
        
    % Si es una iteracion de validacion    
    else
        E_val = 0;
        num_it_val = num_it_val + 1;
        for dato=1:validation_ds_size
            a{1} = validation_ds(dato,1); % Condicion inicial
            % Se propaga hacia adelante el elemento del cto. de
            % validacion.
            for k=1:num_layers
                W_temp = cell2mat(W(k));
                a_temp = cell2mat(a(k));
                b_temp = cell2mat(b(k));
                a{k+1} = funcionDeActivacion(W_temp*a_temp+b_temp,fun_capa(k));
            end
            a_temp = cell2mat(a(num_layers+1));
            e_val = validation_ds(dato,2)-a_temp;
            E_val = E_val+(e_val/validation_ds_size);
        end
        
        % Se guarda el valor para graficacion
        valores_graficacion_eval(it) = E_val;
        
        if count_val == 0
            Err_val = E_val;
            count_val = count_val+1;
            fprintf('Count val = %d\n',count_val);
        else
            if E_val > Err_val
                Err_val = E_val;
                count_val = count_val+1;
                fprintf('Count val = %d\n',count_val);
                if count_val == numval
                    early_stopping = 1;
                    fprintf('Early stopping en iteracion %d\n',it);
                    break;
                end
            else
                Err_val = 0;
                count_val = 0;
                fprintf('Count val = %d\n',count_val);
            end
        end
    end
    
    % Se imprimen los valores de pesos y bias modificados a archivo
    num_archivos_pesos = 1;
    num_archivos_bias = 1;
    for k=num_layers:-1:1
        W_temp = cell2mat(W(k));
        b_temp = cell2mat(b(k));
        for j=1:architecture(k+1)
            for l=1:architecture(k)
                fprintf(W_files(num_archivos_pesos),'%f\r\n',W_temp(j,l));
                num_archivos_pesos = num_archivos_pesos +1;
            end
        end
        for j=1:architecture(k+1)
            fprintf(b_files(num_archivos_bias),'%f\r\n',b_temp(j));
            num_archivos_bias = num_archivos_bias + 1;
        end
    end
    
    % Se comprueban las condiciones de finalizacion
    if Eap <= error_epoch_validation && Eap >= 0 && mod(it,validation_iter) ~= 0
        Err_ap = Eap;
        fprintf('Aprendizaje exitoso en la iteracion %d\n',it);
        break;
    end
end

if it == epochmax
    disp('Se llego a epochmax.');
end

% Se imprimen a archivo los ultimos valores de pesos y bias de cada capa
if early_stopping == 1
% Se imprimen los valores de pesos y bias modificados a archivo
    num_archivos_pesos = 1;
    num_archivos_bias = 1;
    for k=num_layers:-1:1
        W_temp = cell2mat(W(k));
        b_temp = cell2mat(b(k));
        for j=1:architecture(k+1)
            for l=1:architecture(k)
                fprintf(W_files(num_archivos_pesos),'%f\r\n',W_temp(j,l));
                num_archivos_pesos = num_archivos_pesos +1;
            end
        end
        for j=1:architecture(k+1)
            fprintf(b_files(num_archivos_bias),'%f\r\n',b_temp(j));
            num_archivos_bias = num_archivos_bias + 1;
        end
    end
end

% Se cierran los archivos de valores de graficacion de pesos y bias
for i=1:total_weight_files
    fclose(W_files(i));
end
for i=1:total_bias_files
    fclose(b_files(i));
end

% Se propaga el conjunto de prueba
Ep = 0; % Error de prueba
salida_red = zeros(test_ds_size,1);
for i=1:test_ds_size
    a{1} = test_ds(i,1); % Condicion inicial
    % Se propaga hacia adelante el elemento del cto. de prueba
    for k=1:num_layers
        W_temp = cell2mat(W(k));
        a_temp = cell2mat(a(k));
        b_temp = cell2mat(b(k));
        a{k+1} = funcionDeActivacion(W_temp*a_temp+b_temp,fun_capa(k));
    end
    dato_entrada = cell2mat(a(1));
    a_temp = cell2mat(a(num_layers+1));
    Ep = Ep+(1/test_ds_size)*(test_ds(i,2)-a_temp);
    salida_red(i) = a_temp;
end

% Se imprimen los valores finales de Eap, Ep y Eval
fprintf('Eap = %f\n',Err_ap);
fprintf('Eval = %f\n',Err_val);
fprintf('Ep = %f\n',Ep);

% Graficacion del conjunto de prueba, se muestran los targets contra los
% resultados de la red.
figure
rango = test_ds(:,1);
s1 = scatter(rango,salida_red,'d');
s1.MarkerFaceColor = [0 0 1];
s1.MarkerEdgeColor = 'b';
grid on
hold on
s2 = scatter(rango,test_ds(:,2));
s2.MarkerFaceColor = [1 0 1];
s2.MarkerEdgeColor = 'm';
title('Target v.s. Salida de la red (Cto. Prueba)');
ylabel('f(p)');
xlabel('p');
lgd = legend('Salida de la red','Target','Location','northeastoutside');
title(lgd,'Simbología');
hold off

% Se propaga el conjunto de entrenamiento
salida_red = zeros(training_ds_size,1);
for i=1:training_ds_size
    a{1} = training_ds(i,1); % Condicion inicial
    % Se propaga hacia adelante el elemento del cto. de
    % entrenamiento
    for k=1:num_layers
        W_temp = cell2mat(W(k));
        a_temp = cell2mat(a(k));
        b_temp = cell2mat(b(k));
        a{k+1} = funcionDeActivacion(W_temp*a_temp+b_temp,fun_capa(k));
    end
    dato_entrada = cell2mat(a(1));
    a_temp = cell2mat(a(num_layers+1));
    Ep = Ep+(1/training_ds_size)*(training_ds(i,2)-a_temp);
    salida_red(i) = a_temp;
end

% Graficacion del conjunto de entrenamiento, se muestran los targets contra
% los resultados de la red.
figure
rango = training_ds(:,1);
plot(rango,salida_red);
grid on
hold on
plot(rango,training_ds(:,2));
title('Target v.s. Salida de la red (Cto. Entrenamiento)');
ylabel('f(p)');
xlabel('p');
lgd = legend('Salida de la red','Target','Location','northeastoutside');
title(lgd,'Simbología');
hold off

% Se grafica la evolucion de los errores de aprendizaje y validacion por
% epoca.
figure
rango = 1:1:it;
rango2 = validation_iter:validation_iter:num_it_val*validation_iter;
s1 = scatter(rango,valores_graficacion_eap(1:it,1));
s1.MarkerFaceColor = [0 1 0];
s1.MarkerEdgeColor = 'g';
grid on
hold on
s2 = scatter(rango2,valores_graficacion_eval(validation_iter:validation_iter:num_it_val*validation_iter,1),'d');
s2.MarkerFaceColor = [1 0 0];
s2.MarkerEdgeColor = 'r';
title('Error de aprendizaje y Error de validacion');
ylabel('Valor del error');
xlabel('Iteracion');
lgd = legend('Eap','Eval','Location','northeastoutside');
title(lgd,'Simbología');
hold off

%Se grafica la evolucion de los pesos
rango = 0:1:it;
for i=1:num_layers
    figure
    path = strcat(pwd,'/historico/capa_',num2str(i),'/pesos/');
    for j=1:architecture(i+1)
        for k=1:architecture(i)
            archivo_pesos = strcat(path,'/pesos',num2str(j),'_',num2str(k),'.txt');
            simb = strcat('W(',num2str(j),',',num2str(k),')');
            evolucion_pesos = importdata(archivo_pesos); % Identificador para la grafica
            plot(rango,evolucion_pesos','DisplayName',simb);
            hold on
            grid on
        end
    end
    titulo = strcat('Evolucion de los pesos de la capa',{' '},num2str(i));
    title(titulo);
    ylabel('Valor de los pesos');
    xlabel('Iteracion');
    lgd = legend('show','Location','northeastoutside');
    title(lgd,'Simbología');
    hold off
end

%Se grafica la evolucion de los bias
rango = 0:1:it;
for i=1:num_layers
    figure
    path = strcat(pwd,'/historico/capa_',num2str(i),'/bias/');
    for j=1:architecture(i+1)
        archivo_bias = strcat(path,'/bias',num2str(j),'.txt');
        simb = strcat('b(',num2str(j),')');
        evolucion_bias = importdata(archivo_bias); % Identificador para la grafica
        plot(rango,evolucion_bias','DisplayName',simb);
        hold on
        grid on
    end
    titulo = strcat('Evolucion de los bias de la capa',{' '},num2str(i));
    title(titulo);
    ylabel('Valor de los bias');
    xlabel('Iteracion');
    lgd = legend('show','Location','northeastoutside');
    title(lgd,'Simbología');
    hold off
end

for i=1:num_layers
    path = strcat(pwd,'/Resultados-finales/capa_',num2str(i),'/');
    if ~exist(path, 'dir')
        mkdir(path);
    end
    W_temp = cell2mat(W(i));
    res_pesos = strcat(path,'/pesos.txt');
    dlmwrite(res_pesos,W_temp,';');
end

for i=1:num_layers
    path = strcat(pwd,'/Resultados-finales/capa_',num2str(i),'/');
    if ~exist(path, 'dir')
        mkdir(path);
    end
    b_temp = cell2mat(b(i));
    res_bias = strcat(path,'/bias.txt');
    dlmwrite(res_bias,b_temp,';');
end
