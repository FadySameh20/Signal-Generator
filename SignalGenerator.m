fprintf('\n<strong>------------------------------ Signal Generator ------------------------------</strong>\n');  %<strong> is used to make the statment bold

flag = true;
while flag    
    fs = validate('\nPlease enter the sampling frequency of the signal: ', true);
    while fs == 0
       fs = validate('Frequency sampling must not be zero. Please enter a valid frequency sampling : ', true); 
    end

    start_time = validate('Please enter the start of time scale: ', false);

    end_time = validate('Please enter the end of time scale: ', false);
    while end_time <= start_time      %end_time must be greater than the start_time
        end_time = validate('End of time must be greater than the start of time. Please enter a valid end of time scale: ', false);
    end

    break_points = validate('Please enter the number of break points: ', true);    %break_points can't be negative

    pos = [];
    i = 1;
    while i <= break_points
        pos(i) = validate(['The position of break point ' num2str(i) ' at t = '], false);
        if pos(i) > start_time && pos(i) < end_time
            i = i + 1;
        else
            fprintf('Invalid break point position. Break point must lie between starting time and ending time.\n');
        end
    end
    pos = sort(pos);   %if the user entered the breakpoints at unsorted time values

    x = [];
    i = 1;
    temp_start = start_time;
    if break_points == 0     %only one time interval
        temp_end = end_time;
    else       %more the one time interval [end of current inerval is the start of the next interval (break point)]
        temp_end = pos(1);
    end

    fprintf('\nChoose one of the following signals:\na. DC signal\nb. Ramp signal\nc. General order polynomial\nd. Exponential signal\ne. Sinusoidal signal\n');
    while true
        signal_type = input(['\nPlease enter the signal type in region ' num2str(i) ': '], 's');
        if (i>1) && (i <= break_points+1)
            temp_start = pos(i-1);    %set the start of the interval
            if i == break_points+1    %last interval
                temp_end = end_time;
            else    
                temp_end = pos(i);    %set the end of the interval
            end
        end
        t = linspace(temp_start, temp_end, (temp_end - temp_start) * fs);
        switch signal_type
            case 'a'
                amp = validate('Please enter the amplitude: ', false);
                x = [x, amp .* ones(1, (temp_end - temp_start) * fs)];
            case 'b'
                slope = validate('Please enter the slope: ', false);
                intercept = validate('Please enter the intercept: ', false);
                x = [x, (slope.*t + intercept).*(t>=0)];     %ramp is a causal function defined for (t>=0) only
            case 'c'
                pow = validate('Please enter the power (order of the polynomial): ', true);
                while pow ~= floor(pow)     %if the order of polynomial is not an integer
                    pow = validate('Order of the polynomial must be an integer. Please enter a valid polynomial order: ', true);
                end
                poly = 0;
                for j = pow:-1:0
                    coeff = validate(['Please enter the coefficient of t\^', num2str(j), ': '], false);
                    poly = poly + coeff.*(t.^j);
                end
                amp = validate('Please enter the amplitude: ', false);
                x = [x, amp.*poly];
            case 'd'
                amp = validate('Please enter the amplitude: ', false);
                exponent = validate('Please enter the exponent: ', false);
                x = [x, amp.*exp(exponent.*t)];
            case 'e'
                amp = validate('Please enter the amplitude: ', false);
                f = validate('Please enter the frequency: ', true);
                phase = validate('Please enter the phase: ', false);
                x = [x, amp.*sin(2.*pi.*f.*t + phase)];
            otherwise
                disp('Invalid input !!');
                continue;
        end
        if i > break_points
            break;
        end
        i = i+1;
    end

    x = [zeros(1,1*fs), x, zeros(1,1*fs)];   % added zero at the begining and end of the graph to make it clear
    tot_t = linspace(start_time - 1, end_time + 1, (end_time - start_time + 2) * fs);
    figure; plot(tot_t,x); grid on;
    xlabel('t (sec)', 'fontweight', 'bold'); ylabel('x(t)', 'fontweight', 'bold'); title('Signal Generator', 'fontweight', 'bold');

    fprintf('\nChoose one of the following operations to be performed:\na. Amplitude Scaling\nb. Time reversal\nc. Time shift\nd. Expanding the signal\ne. Compressing the signal\nf. None\n');
    while true
        operation = input('\nPlease enter the operation: ', 's');
        switch operation
            case 'a'
                scale = validate('Please enter the scale value: ', false);
                x = scale.*x;
                figure; plot(tot_t,x); grid on;
                xlabel('t (sec)', 'fontweight', 'bold'); ylabel([num2str(scale) 'x(t)'], 'fontweight', 'bold'); title('Amplitude Scaling', 'fontweight', 'bold');
            case 'b'
                tot_t = tot_t .* -1;
                figure; plot(tot_t,x); grid on;
                xlabel('t (sec)', 'fontweight', 'bold'); ylabel('x(-t)', 'fontweight', 'bold'); title('Time Reversal', 'fontweight', 'bold');
            case 'c'
                shift = validate('Please enter the shift value: ', false);
                tot_t = tot_t + shift;     %if the user entered a positive value, the signal will be shifted to the right
                figure; plot(tot_t,x); grid on;
                if shift >= 0
                    sign = '-';
                else
                    sign = '+';
                end
                xlabel('t (sec)', 'fontweight', 'bold'); ylabel(['x(t ' sign ' ' num2str(abs(shift)) ')'], 'fontweight', 'bold'); title('Time Shifting', 'fontweight', 'bold');
            case 'd'
                expanding = validate('Please enter the expanding value: ', true);      %Expanding value can't be negative in order not to reverse the signal
                while expanding == 0
                   expanding = validate('Expanding value must not be zero. Please enter a valid expanding value : ', true); 
                end
                tot_t = tot_t .* expanding;
                figure; plot(tot_t,x); grid on;
                xlabel('t (sec)', 'fontweight', 'bold'); ylabel(['x(t/' num2str(expanding) ')'], 'fontweight', 'bold'); title('Signal Expansion', 'fontweight', 'bold');
            case 'e'
                compressing = validate('Please enter the compressing value: ', true);    %Compressing value can't be negative in order not to reverse the signal
                while compressing == 0
                   compressing = validate('Compressing value must not be zero. Please enter a valid compressing value : ', true); 
                end
                tot_t = tot_t ./ compressing;
                figure; plot(tot_t,x); grid on;
                xlabel('t (sec)', 'fontweight', 'bold'); ylabel(['x(' num2str(compressing) 't)'], 'fontweight', 'bold'); title('Signal Compression', 'fontweight', 'bold');
            case 'f'
                break;
            otherwise
                disp('Invalid input !!');
                continue;
        end
    end
    
    while true
        choice = input('\nWould you like to generate another signal ?\na. Yes\nb. No\nYour choice is: ', 's');
        switch choice
            case 'a'
                flag = true;
                break;
            case 'b'
                flag = false;
                fprintf('\n');
                break;
            otherwise
                disp('Invalid input !!');
                continue;
        end
    end
end