function [training_ds, test_ds, validation_ds] = dataset_slices (opcion, inputs, targets)
    % Get the data size
    num_data = size (inputs, 1)
    % COnfiguration options
    if opcion == 1
        training_num = ceil (num_data * .8);
        test_num = floor (num_data * 0.1 );
        validation_num =  floor (num_data * 0.1);
    else
        training_num = ceil (num_data * 0.7)
        test_num = floor (num_data * 0.15)
        validation_num =  floor (num_data * 0.15)
    end
    % Initialize the datasets
    training_ds = zeros (training_num, 2);
    test_ds = zeros (test_num, 2);
    validation_ds = zeros (validation_num, 2);
    a1 = 2:ceil(num_data / validation_num):num_data-1
    aux = setdiff(1:num_data, a1);
    j = 2;
    a2 = [];
    increment = ceil(size(aux, 2) / test_num);
    for i=1:test_num
        if (j < size(aux, 2))
            a2 = [a2, aux(j)];
        else
            a2 = [a2, aux(end - 1)];
        end
        j = j + increment;
    end
    a2
    a3 = setdiff(aux, a2)
    
    % Validation Slice
    for i = 1:size(a1, 2)
        validation_ds (i, 1) = inputs(a1(i));
        validation_ds (i, 2) = targets(a1(i));
    end    
 
   % test Slice
    for i = 1:size(a2, 2)
        test_ds (i, 1) = inputs(a2(i));
        test_ds (i, 2) = targets(a2(i));
    end   
    
    
     % training Slice
    for i = 1:size(a3, 2)
        training_ds(i, 1) = inputs(a3(i));
        training_ds(i, 2) = targets(a3(i));
    end  
end
