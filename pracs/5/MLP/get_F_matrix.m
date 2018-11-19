function F = get_F_matrix(option, total_neurons, a)
    if (option == 1)
        F = diag(ones(1, total_neurons));
    elseif (option == 2)
        F = diag(logsig('dn', a, a));
    else
        F = diag(tansig('dn', a, a));
    end
end
