% Datos ingresados por el usuario
p = str2num(input('Ingrese el vector de entrada. Los valores separados por espacios (e.g. 1 2 3)\n', 's'))';
b = str2num(input('Ingrese el vector de bias. Los valores separados por espacios (e.g. 1 2 3)\n', 's'))';
W = dlmread('matrix.txt')
% Capa Feed Foward

n = W*p + b;
a = poslin(n);
