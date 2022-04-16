function detect_facemask_cam(boosted_classifiers, weak_classifiers, face_size, positives, negatives,net,scales, result_num)

%%Example WEBCAM custom preview window for MATLAB R2017a
%%List connected webcams
webcamlist
%%Connect to webcam
c = webcam(1);
fig = figure('NumberTitle', 'off', 'MenuBar', 'none');
fig.Name = 'My Camera';
ax = axes(fig);
axis(ax, 'image');
frame = snapshot(c);
im = image(ax, zeros(size(frame), 'uint8'));
preview(c, im);
setappdata(fig, 'cam', c);
fig.CloseRequestFcn= @closePreviewWindow_Callback;
%fig.WindowButtonMotionFcn=@detect_facemask;
closeApp = 0
rectanlges = [];

tStart = tic;
tEnd = 0;
while ~closeApp
    %if tEnd > .1
    detect_facemask();
    %   tStart = tic;
    %end
    %tEnd = toc(tStart);
end


    function closePreviewWindow_Callback(obj, ~)
        closeApp = 1;
        c = getappdata(obj, 'cam');
        closePreview(c);
        clear('c');
        delete(obj);
    end

    function deleteDraw()
        for i = 1:length(rectanlges)
            if ~isempty(fig) && ~isempty(rectanlges(i))
                delete(findobj('Type','Rectangle'));
                delete(findall(gcf,'type','annotation'));
            end
        end
        rectanlges = [];
    end

    function detect_facemask()
        img = snapshot(c);
        if(size(positives,1) >0)
            [result, boxes] = boosted_detector_skin_demo(img, scales, boosted_classifiers, weak_classifiers, face_size, positives, negatives, result_num);
        else
            [result, boxes] = boosted_detector_demo(img, scales, boosted_classifiers, weak_classifiers, face_size,result_num);
            
        end
        boxes = facemask_classifier(img, net, boxes);
        deleteDraw();
        for i = 1:length(boxes)
            if boxes(i).nonMax == 1
                if boxes(i).cnnFaceMaskProb > 0.6
                    rectanlges(i) = rectangle('Position', ...
                        [boxes(i).coords(2),boxes(i).coords(1),boxes(i).coords(3),boxes(i).coords(4)],...
                        'EdgeColor','g','LineWidth',2 );
                    [x,y] = normalize_coordinate(boxes(i).coords(2)+2,boxes(i).coords(1) + floor(boxes(i).coords(3)/2), get(gca, 'Position'), get(gca, 'xlim'), get(gca, 'ylim'),0,0);
                    annotation('textbox',[x(1), y(1),.1,.1],'String','FaceMask','Color','green');
                elseif boxes(i).cnnFaceProb > 0.6
                    rectanlges(i) = rectangle('Position',[boxes(i).coords(2),boxes(i).coords(1),boxes(i).coords(3),boxes(i).coords(4)],'EdgeColor','r','LineWidth',2 );
                    [x,y] = normalize_coordinate(boxes(i).coords(2)+2,boxes(i).coords(1) + floor(boxes(i).coords(3)/2), get(gca, 'Position'), get(gca, 'xlim'), get(gca, 'ylim'),0,0);
                    annotation('textbox',[x(1), y(1),.1,.1],'String','Face','Color','red');
                end
            end
            drawnow;
        end
    end

end
