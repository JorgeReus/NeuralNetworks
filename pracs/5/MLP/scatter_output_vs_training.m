function scatter_output_vs_training(training_ds, output)
    % Targets vs MLP output PLOT
    figure('Name','Targets del dataset de entrenamiento vs Output', 'NumberTitle', 'off')
    grid on
    hold on
    title('Targets del dataset de entrenamiento vs Output');
    ylabel('G(p)');
    xlabel('rango de la señal');
    signal_range = training_ds(:, 1);
    % targets
    scatter(signal_range, training_ds(:,2), 'd', 'MarkerEdgeColor', 'black');
    % outputs
    scatter(signal_range, output, 5, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue' ); 
    title(legend('Target', 'Output', 'Location', 'northwestoutside'),'Leyenda');
    hold off
end

