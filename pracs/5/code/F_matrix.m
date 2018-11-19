function F = F_matrix (f, neurons, a)
    if f == 1
        %Purelin
        F = diag (ones (1, neurons));
    elseif f == 2
        %Logsig
        F = diag (logsig ('dn', a, a));
    else
        %Tansig
        F = diag (tansig ('dn', a, a));
    end
end

