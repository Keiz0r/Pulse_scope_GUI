function OK_button(insert_text)
	fgh = figure(3);
	fgh.Name = 'Current increase necessary';
	fgh.NumberTitle = 'off';
	fgh.Visible = 'on';
	text = uicontrol('Parent',fgh,'Style','text','String',insert_text,'Units','normal','FontSize',14,'Position',[0.0,0.65,1,0.3]);
	ok_button = uicontrol('Parent',fgh,'String','OK','Units','normal','FontSize',14,'Position',[0.35,0.2,0.25,0.35],'Backgroundcolor','k','Foregroundcolor','w','Callback','uiresume(3)');
	uiwait(3)