function [circularity, radius] = computeCircularity(boundary)
    % Compute perimeter
    perimeter = 0;
    for idx = 1:(size(boundary,1)-1)
        perimeter = perimeter + sqrt((boundary(idx+1,1)-boundary(idx,1))^2 + ...
                                     (boundary(idx+1,2)-boundary(idx,2))^2);
    end
    % Close the polygon
    perimeter = perimeter + sqrt((boundary(end,1)-boundary(1,1))^2 + ...
                                 (boundary(end,2)-boundary(1,2))^2);

    % Compute area
    x = boundary(:,2);
    y = boundary(:,1);
    area = polyarea(x,y);

    if perimeter == 0
        circularity = 0;
        radius = 0;
        return;
    end

    circularity = (4 * pi * area) / (perimeter^2);
    radius = sqrt(area/pi);
end
