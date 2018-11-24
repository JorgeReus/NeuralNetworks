function error_plot(validation_iter, num_validation_epoch, learning_err_values, epoch, evaluation_err_values)
    figure('Name','Evolución de error de aprendizaje y de validacion', 'NumberTitle', 'off')
    grid on
    hold on
    num_epochs = 1:1:epoch;
    increments = validation_iter:validation_iter:num_validation_epoch*validation_iter;
    scatter(num_epochs,learning_err_values(1:epoch,1), 'MarkerFaceColor', 'green', 'MarkerEdgeColor', 'green');
    scatter(increments,evaluation_err_values(validation_iter:validation_iter:num_validation_epoch*validation_iter,1), 'd', 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    title('Evoluación de error de aprendizaje y de validacion');
    xlabel('Epoch');
    ylabel('Error');
    title(legend('Error aprendizaje', 'Error validación', 'Location', 'northwestoutside'),'Leyenda');
    hold off
end