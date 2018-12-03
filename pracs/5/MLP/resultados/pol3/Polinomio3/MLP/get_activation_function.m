function a = get_activation_function(n, config)
    if (config == 1)
        a = purelin(n);
    elseif (config == 2)
        a = logsig(n);
    else
        a = tansig(n);
    end
end