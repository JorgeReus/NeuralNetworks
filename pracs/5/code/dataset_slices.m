function [training_ds, test_ds, validation_ds] = dataset_slices (opcion, inputs, targets)
    % Get the data size
    num_data = size (inputs, 2);
    % COnfiguration options
    if opcion == 1
        training_num = ceil (num_data * .8);
        test_num = floor (num_data * 0.1 );
        validation_num =  floor (num_data * 0.1);
    else
        training_num = ceil (num_data * 0.7);
        test_num = floor (num_data * 0.15);
        validation_num =  floor (num_data * 0.15);
    end
    % Initialize the datasets
    training_ds = zeros (training_num, 2);
    test_ds = zeros (test_num, 2);
    validation_ds = zeros (validation_num, 2);
    % The training dataset has to cover all the range
    training_ds(1, 1) = inputs(1);
    inputs(1) = [];
    training_ds(1, 2) = targets(1);
    targets(1) = [];
    training_ds(2, 1) = inputs(end);
    inputs(end) = [];
    training_ds(2, 2) = targets(end);
    targets(end) = [];
    % Shufflle the datasets
    shuffled_values = randperm (num_data - 2);
    inputs = inputs(shuffled_values);
    targets = targets(shuffled_values);
    
    % Training Slice
    for i = 3:training_num
        training_ds (i, 1) = inputs (i - 2);
        training_ds (i, 2) = targets (i - 2);
    end
    inputs = inputs(training_num - 1: end);
    targets = targets(training_num - 1: end);
    % Test Slice
    for i = 1:test_num
        test_ds (i, 1) = inputs (i);
        test_ds (i, 2) = targets (i);
    end
    inputs = inputs(validation_num + 1: end);
    targets = targets(validation_num + 1: end);
    % Validation Slice
    for i = 1:validation_num
        validation_ds (i, 1) = inputs (i);
        validation_ds (i, 2) = targets (i);
    end
end
