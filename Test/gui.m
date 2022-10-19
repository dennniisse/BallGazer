
%% Selection
opts.Interpreter = 'tex';
% Include the desired Default answer
opts.Default = 'Red';
% Use the TeX interpreter to format the question
quest = 'Select colour to identify';
answer = questdlg(quest, 'Colour Selection', 'Random', 'Red','Blue', opts);

switch answer
    %% Build Wall Section
    case 'Random'
        
    case 'Red'
end



prompt = {'Enter the depth obtained from the depth map'};
dlgtitle = 'Depth (mm)';
self.ballCentroid(3) = inputdlg(prompt,dlgtitle);
%%

t = timer('StartDelay',2,...
    'TimerFcn',@(~,~)delete(findall(groot,'WindowStyle','modal')));
start(t)

tic
f = msgbox(["The selected colour is: "])';

toc

