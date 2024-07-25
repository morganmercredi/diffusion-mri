function h = print_axon_distribution(cylinder_file, axon_pdf, pars, covPars, rmin, rmax, rincrements)
% Creates a figure showing the true axon diameter distribution and the predicted diameter distribution
% 
% Output
%   h: handle to final figure
%
% Input
%   cylinder_file: name of the text file with the cylinder information
%   axon_pdf: function handle specifying the diameter distribution, 'gampdf' or
%       'normpdf'
%   pars: vector with parameters for the diameter distribution pdf
%   covPars: covariance matrix for fitted parameters
%   rmin: minimum radius
%   rmax: maximum radius
%   rincrements: number of bins

% Number of unique cylinders in the simulation
number_of_cylinders = 100;

% Open simulation file and save radius values
centers_and_radii = importdata(cylinder_file);
radii = centers_and_radii(1:number_of_cylinders, 4);

% Set bin widths and bin cylinder radii
binranges = rmin:(rmax-rmin)/rincrements:rmax;
[bincounts ind] = histc(radii, binranges);
numFraction = bincounts/length(radii);

% Calculate distribution from fitted parameters
%ri = linspace(0.00001, 0.005, 1000);
ri = binranges(1:(end-1)) + diff(binranges)/2;
axon_distribution = axon_pdf(ri, pars(1), pars(2));
axon_distribution = axon_distribution./sum(axon_distribution);

% Calculate and print mean radius
mean_diameter = 2*1000*sum(axon_distribution.*ri);
fprintf('The actual mean diameter is %.8f.\n', 2*1000*mean(radii));
fprintf('The predicted mean diameter is %.8f.\n', mean_diameter);    

% Make the figure
figure;
xlabel('Diameter (\mum)','FontSize',12);
ylabel('Fraction of axons','FontSize',12);
xlim([2*binranges(1)*1e3, 2*binranges(end)*1e3]);
hold on;
h(1) = bar(2*binranges*1e3, numFraction, 'histc');
set(h, 'FaceColor', 'r', 'EdgeColor', 'r');
h(2) = plot(ri*2*1e3, axon_distribution, 'k', 'LineWidth', 4.5);
set(gca,'FontSize',10);
hold off;

end

