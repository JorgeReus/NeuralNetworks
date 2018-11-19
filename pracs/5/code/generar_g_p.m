function generar_g_p (iter)
    
    path = strcat (pwd, '/test_functions/g_p ');
    if ~exist (path, 'dir')
         mkdir (path);
    end

    increment = 0.04;
    p = -2:increment:2;
    % Write the inputs
    dlmwrite(strcat(path,'/inputs.txt'), p, 'precision','%.6f');
    i = 2^iter;
    g_p = 1 + sin(i * pi / 4 * p);
    dlmwrite(strcat(path,'/targets.txt'), g_p, 'precision','%.6f');
end