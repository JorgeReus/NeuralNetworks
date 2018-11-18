function [entrenamiento, nuevos_val] = datos_entrenamiento (opcion, valores, inputs, targets)
    if opcion == 1
        aux = 0.8;
    else
        aux = 0.7;
    end
    total_datos = size (valores, 2);
    %Numero de datos para el conjunto de entrenamiento
    datos_ent = ceil (total_datos * aux);
    entrenamiento = zeros (datos_ent, 2);
    %Se comienzan a asignar los valores al conjunto de entrenamiento
    for i = 1:datos_ent
        %Valores de entrenamiento en columna 1
        entrenamiento (i, 1) = inputs (valores (i));
        %Valores de target en la columna 2
        entrenamiento (i, 2) = targets (valores (i));
    end
    %Omitimos los datos ya ingresados para evitar repeticiones
    nuevos_val = valores (i + 1:total_datos);
end
