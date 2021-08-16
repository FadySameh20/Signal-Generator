function val = validate(str, flag)
    val = str2double(input(str,'s'));
    while true
        if isnan(val)   %if the input is not a number
            val = str2double(input('Invalid input. You must enter a number: ','s'));
        else            %Some inputs (numbers) can't be negative such as: frequency and order of polynomial
            if flag == true    
                if val < 0    %if it is a negative number
                    val = str2double(input('Invalid input. You must enter a non-negative number: ','s'));
                else
                    break;
                end
            else
                break;
            end
        end
    end
end