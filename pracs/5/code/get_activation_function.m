function a = get_activation_function (W, a, b, f)
    if f == 1
        %Purelin
        a = purelin ((W * a) + b);
    elseif f == 2
        %Logsig
        a = logsig ((W * a) + b);
    else
        % Tansing
        a = tansig ((W * a) + b);
    end
end