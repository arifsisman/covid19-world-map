contents = readmatrix('data/covid-19-all.csv');

x = contents(:, 3);
y = contents(:, 4);
diseased = contents(:, 5);

% if diseased is NaN it is 1
diseased(isnan(diseased)) = 1;
% x and y are round at 4 decimal precision for remove duplicate data
x = round(x, 4);
y = round(y, 4);

data = [x, y, diseased];
data = sortrows(data, 3, 'descend');
[~, confirmed] = unique(data(:, 1:2), 'rows', 'stable');
data = data(confirmed, :);

avgConfirmed = mean(data(:, 3));

worldmap('world')
load coastlines
plotm(coastlat, coastlon)
scatterm(data(:, 1), data(:, 2), 10, data(:, 3),'.');
hold on

for k = 1:10
    scatterm(data(k, 1), data(k, 2), 'ro');
    textm(data(k, 1), data(k, 2) + 2, num2str(data(k, 3)))
    info = sprintf('Place [%d] = %f, %f [%d confirmed]', k, data(k, 1), data(k, 2), data(k, 3));
    disp(info);
end

hold off

print('-dpng', "figures/covid19_top10");

figure(2);

% ksdensity function is using for computing the probability density
% function for each data vector
[xpdf, xindex]= ksdensity(data(:, 1), 'weights', data(:, 3));
[ypdf, yindex]= ksdensity(data(:, 2), 'weights', data(:, 3));


% Creating the 2D grid of x and y vectors
[meshxindex, meshyindex] = meshgrid(xindex,yindex);
[xpdfx,ypdfy] = meshgrid(xpdf,ypdf);

% Calculating the combined pdf
pdfcombined = xpdfx.*ypdfy;

% Ploting the 3D mesh
mesh(meshxindex, meshyindex, pdfcombined)

print('-dpng', "figures/covid19_density_graph");