% Datos ingresados por el usuario
proto_prompt = ['Ingrese la matriz de los valores prototipos. ' ...
'Las columnas separados por espacios y las filas con ;  (e.g. 1 2 3;4 5 6;7 8 9)\n'];
cell_arr = regexp(input(proto_prompt, 's'),';','split');
p = str2num(input('Ingrese el vector de entrada. Los valores separados por espacios (e.g. 1 2 3)\n', 's'))';
% Capa Feed Foward
W1=[];
for i=1:length(cell_arr)
    % Agregar la columna "parseada" nueva al final de la matriz
    W1 = [W1; str2num(cell_arr{i})];
end
n = size(W1, 1);
b1 = ones(n,1) * size(W1, 2);
a1 = W1 * p + b1;
% Capa Recurrente
epsilon = 1 / n;
W2(1:n, 1:n)=-epsilon;
W2(1:n+1:end)=1;

% Condiciones Iniciales
a2 = a1;
h_values = zeros(1, n);
h_values = [h_values;a1'];
a2 = poslin(W2*a2);
% Valores Extra
h_values = [h_values; a2'];
tries = 40;
winners = 0;
has_converged = false;
% Iteraciones
for i = 1:tries
    has_winner = find_winner(a2);
    if(has_winner)
        winners = winners + 1;
    else
        has_winners = 0;
    end
    if(winners == 2)
        has_converged = true;
        break;
    end
    a2 = poslin(W2*a2);
    h_values = [h_values; a2'];
end

if (has_converged)
    for proto = 1:length(a2)
        if (a2(proto) > 0)
            fprintf('El vector de entrada pertenece a la clase: %d\n', proto);
            break;
        end
    end
else
    fprintf("La red no convergió\n");
end

plot(0:i + 1, h_values');

% Función para encontrar las neuronas encendiades en el vector a
function [is_winner] = find_winner(vector)
    counter = 0;
    for i = 1:size(vector, 1)
        if(vector(i) > 0)
            counter = counter + 1;
        end 
    end
    if counter ~= 1
        is_winner = false;
    else
        is_winner = true;
    end
end
