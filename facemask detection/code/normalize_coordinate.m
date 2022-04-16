function [nx, ny] = normalize_coordinate(x_point_, y_point_, axes, xlims_, ylims_, xlog_bool, ylog_bool)
if xlog_bool && ylog_bool, % loglog plots
    x_point = log(x_point_);
    y_point = log(y_point_);
    xlims = log(xlims_);
    ylims = log(ylims_);
elseif xlog_bool, % semilogx plots
    x_point = log(x_point_);
    y_point = y_point_;
    xlims = log(xlims_);
    ylims = ylims_;
elseif ylog_bool, % semilogy plots
    x_point = x_point_;
    y_point = log(y_point_);
    xlims = xlims_;
    ylims = log(ylims_);
else % plot plots
    x_point = x_point_;
    y_point = y_point_;
    xlims = xlims_;
    ylims = ylims_;
end

nx = ((x_point-xlims(1))/(xlims(2) - xlims(1)))*axes(3);
ny = ((y_point-ylims(1))/(ylims(2) - ylims(1)))*axes(4);
nx = axes(1) + nx;
ny = axes(2) + ny;
end