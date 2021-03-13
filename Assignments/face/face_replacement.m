%% tempalte setup
template = read_gray('quo_template.jpg');

template(90:160, 620:680)=0;
for i=1:30
    template(160:160+i, 620+i:680-i)=0;
end


figure(1); imshow(template, []);

%% face detection
