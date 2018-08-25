% Se proponen los siguientes valores
w = input('Ingrese el valor del peso sináptico: ');
theta = input('Ingrese el valor del umbral: ');

% w = -1;
% theta = -1;

% Entradas y targets
p1 = 1;
t1 = 0;
p2 = 0;
t2 = 1;

error = false;
% Iteración
n1 = p1 * w;
if n1 > theta
    a1 = 1;
else
    a1 = 0;
end
if t1 ~= a1
    error = true;
end

n2 = p2 * w;
if n2 > theta
    a2 = 1;
else
    a2 = 0;
end

if t2 ~= a2
    error = true;
end

if ~error
    fprintf("El aprendizaje fue exitoso\n")
else
    fprintf("Aprendizaje erróneo")
end

