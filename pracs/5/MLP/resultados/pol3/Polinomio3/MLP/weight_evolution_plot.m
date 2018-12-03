function weight_evolution_plot(architecture, num_layers, epoch)
    num_epochs = 0:1:epoch;
    for i=1:num_layers
        figure('Name',sprintf('Evolución de pesos capa %d', i), 'NumberTitle', 'off')
        path = strcat(pwd, '/historico/capa_', num2str(i), '/pesos/');
        for j = 1:architecture(i + 1)
            for k = 1:architecture(i)
                W_file = strcat(path, '/pesos',num2str(j), '_', num2str(k), '.txt');
                identifier = strcat('W(',num2str(j),',',num2str(k),')');
                evolution = importdata(W_file);
                plot(num_epochs, evolution', 'DisplayName', identifier);
                hold on
                grid on
            end
        end
        title(sprintf('Evolución de pesos capa %d', i));
        xlabel('Epoch');
        ylabel('Valor');
        title(legend('show', 'Location', 'northwestoutside'), 'Leyenda');
        hold off
    end
end