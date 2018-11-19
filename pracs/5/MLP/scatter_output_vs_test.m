function scatter_output_vs_test(test_ds, output)
    % Targets vs MLP output PLOT
    figure('Name','Targets del dataset de prueba vs Output', 'NumberTitle', 'off')
    grid on
    hold on
    title('Targets del dataset de prueba vs Output');
    ylabel('G(p)');
    xlabel('rango de la señal');
    signal_range = test_ds(:, 1);
    % targets
    scatter(signal_range,test_ds(:,2), 'd', 'MarkerEdgeColor', 'black');
    % outputs
    scatter(signal_range, output, 5, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue' ); 
    title(legend('Target', 'Output', 'Location', 'northwestoutside'),'Leyenda');
    hold off
end