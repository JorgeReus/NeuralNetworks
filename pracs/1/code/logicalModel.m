function [table] = logicalModel(i, gate)
    % logicalModel(I, gate) returns a matrix representing a truth table and
    % the last column represents the oupot base on all the previous columns
    % based on the (gate) parameter
    % INPUT: (I) shall be an integer >= 1
    % INPUT: (gate) shall be 'and' or 'or'
    % OUTPUT: logicalModel is a binary matrix of size [2^I,I + 1]
    % Heavily inspired in Paul Metcalf's CONDVECTS
    % Acknowledgements: Paul Metcalf
    
    g = 2;
    i2 = 2^i;
    table = false(i2,i + 1);
    for m = 1 : 1 : i
        m2 = 2^m;
        m3 = (m2/2)-1;
        i3 = i-m+1;
        for g = g : m2 : i2
            for k = 0 : 1 : m3
                table(g+k,i3) = true;
            end
        end
        g = m2+1;
    end
    if (gate == "and")
          for row_index = 1:size(table, 1)
            row = table(row_index,:);
            res = row(1);     
            for e_index = 1:size(row, 2)-1
                res = res & row(e_index);
            end
            table(row_index, end) = res; 
          end  
    elseif (gate == "or")
        for row_index = 1:size(table, 1)
            row = table(row_index,:);
            res = row(1);     
            for e_index = 1:size(row, 2)-1
                res = res | row(e_index);
            end
            table(row_index, end) = res; 
        end  
    end 
    
end