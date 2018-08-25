% Se proponen los siguientes valores
syn_prompt = 'Ingrese el valor de los pesos sinápticos separados por espacios(i.e. 1 2 3 4): ';
w = str2num(strip(input(syn_prompt, 's')));
theta = input('Ingrese el valor del umbral: ');

% w = [1 1];
% theta = 1;

% Entradas y targets
model = logicalModel(size(w, 2), "and")
     
error = false;
% Iteración
for i = 1:size(model, 1)
    row = model(i, :);
    n = sum(row(1:end-1).*w);
    % Obtención de a
    if(n > theta); a_n = 1; else; a_n=0; end
    % Comparación de a con el target
    fprintf("n_%i = %i -> t_%i = %i\n", i, a_n, i, row(end));
    if(a_n ~= row(end)); error = true; break; end
end

if(~error); fprintf("El aprendizaje fue exitoso\n"); else; fprintf("El aprendizaje no fue exitoso\n"); end