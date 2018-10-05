targets = importdata('targets.txt');
inputs = importdata('inputs.txt');
mode = input('Elija un modo: 1-Gráfico, 2-Regla de Aprendizaje', 's');
if(mode=='1')
    figure
            ax = gca;                        % gets the current axes
ax.XAxisLocation = 'origin';     % sets them to zero
ax.YAxisLocation = 'origin'; 
    hold on
    x = 1:10;
    y = 1:10;

    plot(x, y);

    r = .2;
    for row = inputs.'
        %circle(row(1), row(2), r);
    end
elseif(mode=='2')
    
else
    
end
    
function h = circle(x,y,r)
hold on
th = 0:pi/50:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit, yunit);
hold off
end