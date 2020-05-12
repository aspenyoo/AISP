function defaultplot
set(gca, ...
    'Color'         ,'w'              , ...
    'Box'           , 'off'           , ...
    'TickDir'       , 'out'           , ...
    'TickLength'    , [.02 .02]       , ...
    'XColor'        , zeros(1,3)      , ...
    'YColor'        , zeros(1,3)      , ...
    'FontName'      , 'Helvetica'     , ...
    'LineWidth'     , 1               );
set(gcf, ...
    'color'         ,'w'                 );
%     'color'         ,'none'              );



%     set(htitle,...
%         'FontSize'              , 18                ,...
%         'FontName'              ,'Arial'        ,...
%         'FontWeight'            ,'bold'             );
%     set(hylabel,...
%         'FontName'              ,'Arial'        ,...
%         'FontSize'              , 14                );
%     set(hxlabel,...
%         'FontName'              ,'Arial'        ,...
%         'FontSize'              , 14        );
% 
%     'YMinorTick', 'on'  ,...
set(gca,'TickLength'    , [.02 .02])