% Datos proporcionados por el usuario
gate = input('Ingrese la compuerta (and, or, not): ', 's');
syn_prompt = 'Ingrese el valor de los pesos sinápticos separados por espacios(e.g. 1 2 3 4): ';
w = str2num(strip(input(syn_prompt, 's')));
theta = input('Ingrese el valor del umbral: ');
if (gate == "not" && size(w, 2) > 1)
    fprintf("Error, la compuerta NOT es de una sola entrada");
else
    % Generación de la tabla de entradas y targets
    model = logicalModel(size(w, 2), gate)
    error = false;
    % Iteración
    for i = 1:size(model, 1)
        row = model(i, :);
        % Obtención de n
        n = sum(row(1:end-1).*w);
        % Obtención de a
        if(n > theta); a_n = 1; else; a_n=0; end
        % Comparación de a con el target
        fprintf("n_%i = %i -> t_%i = %i\n", i, a_n, i, row(end));
        if(a_n ~= row(end)); error = true; break; end
    end
    if(~error); fprintf("El aprendizaje fue exitoso\n"); else; fprintf("El aprendizaje no fue exitoso\n"); end
end


function [table] = logicalModel(i, gate)
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
    if (gate == "and")
          for row_index = 1:size(table, 1)
            row = table(row_index,:);
            res = row(1);     
            for e_index = 1:size(row, 2)-1
                res = res & row(e_index);
            end
            table(row_index, end) = res; 
          end  
    elseif (gate == "or")
        for row_index = 1:size(table, 1)
            row = table(row_index,:);
            res = row(1);     
            for e_index = 1:size(row, 2)-1
                res = res | row(e_index);
            end
            table(row_index, end) = res; 
        end 
    elseif (gate == "not")
        for row_index = 1:size(table, 1)
            row = table(row_index,:);
            res = ~row(1);     
            table(row_index, end) = res; 
        end
    end  
end