

% Redoubt event times

disp('Redoubt explosions available: ')
disp('    1,  2,  3,  4,  4.1,  5,  8,  12,  13,  18')
s = input('Select event: ');

if s==1;
    % Explosion 1
    t0 = datenum(2009,03,23,06,35,16);
elseif s==2;
    % Explosion 2
    t0 = datenum(2009,03,23,07,01,52);
elseif s==3;
    % Explosion 3
    t0 = datenum(2009,03,23,08,14,05);
elseif s==4
    % Explosion 4
    t0 = datenum(2009,03,23,09,38,52);
elseif s==4.1
    % Explosion 4a
    t0 = datenum(2009,03,23,09,48,20);
elseif s==5
    % Explosion 5
    t0 = datenum(2009,03,23,12,30,21);
elseif s==8
    % Explosion 8
    t0 = datenum(2009,03,26,17,24,14);
elseif s==12
    % Explosion 12
    t0 = datenum(2009,03,28,01,34,43);
elseif s==13
    % Explosion 13
    t0 = datenum(2009,03,28,03,24,18);
elseif s==2;
    % Explosion 18
    t0 = datenum(2009,03,29,03,23,31);
else
    disp( ' Event number not on file')
end

clear s

% elat =   60.488827777;
% elon = -152.764372222;
% edep = 0;
% eid = [];
% emag = [];