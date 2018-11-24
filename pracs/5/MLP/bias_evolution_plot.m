function bias_evolution_plot(architecture, num_layers, epoch)
    num_epochs = 0:1:epoch;
    for i=1:num_layers
        figure('Name', sprintf('Evolución de bias capa %d', i), 'NumberTitle', 'off')
        path = strcat(pwd, '/historico/capa_', num2str(i), '/bias/');
        for j=1:architecture(i+1)
            file = strcat(path,'/bias',num2str(j),'.txt');
            identifier = strcat('b(',num2str(j),')');
            evolution = importdata(file);
            plot(num_epochs, evolution', 'DisplayName', identifier);
            hold on
            grid on
        end
        title(sprintf('Evolución de bias capa %d', i));
        ylabel('Valor');
        xlabel('Epoch');
        title(legend('show', 'Location', 'northwestoutside'), 'Leyenda');
        hold off
    end
end