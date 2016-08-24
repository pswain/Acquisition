function pointsTable_CellEditCallback(hObject, eventdata)
%

handles=guidata(hObject);
% eventdata =
%
%          Indices: [1 7]
%     PreviousData: '10'
%         EditData: 'double'
%          NewData: 'double'
%            Error: []

%Loop through each changed entry
for n=1:size(eventdata.Indices,1)
    %get generally-useful information
    row=eventdata.Indices(n,1);
    column=eventdata.Indices(n,2);
    table=get(hObject,'Data');
    groupno=cell2mat(table(row,6));
    groups=cell2mat(table(:,6));
    group=groups==groupno;%logical index to all members of the group
    %If one of the exposure times has been altered:
    if column>6%ie an exposure time
        %1. If to a new numeric value - change all others of the same group to that
        %value (unless their exposure time entry is 'double')
        %2. If to 'double' - check that there is at least one other member of that
        %group - if so, leave it. If not - revert to previous value and display an
        %error dialogue.
        %. If any other string - revert to previous value and display an error
        %dialogue
        if isempty(str2num(eventdata.NewData))%the entry is not numeric
            %is it 'double'?
            if strcmp('double',eventdata.NewData)
                %the entry is 'double'
                %are there other members of this group?
                if nnz(group)==1
                    errordlg('There must be more than one member of this position group to do a double exposure','Single point with double exposure');
                    table(row,column)={eventdata.PreviousData};
                end
            else%the entry is a non-numeric string that is not double
                errordlg('Please enter an exposure time (ms) or ''double'' for a double exposure','Incorrect entry in exposure time for point');
                table(row,column)={eventdata.PreviousData};
            end
        else%the entry is numeric - a new exposure time
            %set all group members to this (rounded) exposure time - unless their
            %exposure is 'double'
            nondouble=group;
            for o=1:size(table,1)
                if strcmp({table(o,column)},'double')==1
                    nondouble(o)=false;
                end
                entry=round(str2double({eventdata.NewData}));
                table(nondouble,column)={num2str(entry)};
            end
        end%of if/else statement - is the entry numeric
    end
    %Change in a group - if leaves only one member of a group with double - ask
    %for exposure time entry
    %Set the exposure time to the same as the other group members
    
    if column==6%ie a group number
        %first check if the previous group has only one entry that is
        %'double'
        oldgroupno=eventdata.PreviousData;
        oldgroup=groups==oldgroupno;
        if nnz(oldgroup)==1
            oldgroupmember=find(oldgroup);
            for p=7:size(table,2)%Loop through the channels (ie exposure time columns)
                exposentry=char(table(oldgroupmember,p));
                if isempty(str2num(exposentry))%the entry is not a number
                    if strcmp(exposentry,'double')
                        errordlg(strcat('Groups must have at least one exposure time entered. ''double'' changed to previous exposure time for group_',num2str(oldgroupno),'. Channel:',char(handles.acquisition.channels(p-6,1))),'Old group left with only a double entry');
                        oldexpos=table(row,p);
                        table(oldgroupmember,p)=oldexpos;
                    end
                end
            end
        end
        %Now make sure all members of the selected group have the same
        %exposure times
        if nnz(group)>1%number of members of the input group
            newgroup=group;
            newgroup(row)=0;%don't use the exposure times of the newly-added group member
            groupmembers=find(newgroup);
            for ch=7:size(table,2)%loop through the channels - finding the correct exposure time for each
                exposure=nan;
                count=1;
                while isnan(exposure)
                    exposentry=char(table(groupmembers(count),ch));
                    if isempty(str2num(exposentry))==0%the entry is a number
                        exposure=exposentry;
                    end
                    count=count+1;
                end
                table(row,ch)={exposure};
            end
        end
    end
    if column==1
       %The position name has been edited 
        oldName=handles.acquisition.points{row,1};
        pointNumber=oldName(end-2:end);%String with 3 digits
        newName=table{row,column};
        if strcmp(pointNumber,newName(end-2:end))
            %Only the prefix has been edited
            newPrefix=newName(1:end-3);
        else
            %Part of the number has also been removed - use the whole input
            %string as the new prefix
            newPrefix=newName;
            newName=[newPrefix pointNumber];
            table{row,column}=newName;
        end
        %If the point is part of a group, offer to change the other points
        %in the group
        if nnz(group)>1
            changeGroup=questdlg('Do you want to change the names of all points in this group?');
            if strcmp(changeGroup,'Yes')
                groupInd=find(group);
                for n=1:nnz(group)
                    thisPointNumber=table{groupInd(n)}(end-2:end);
                    table{groupInd(n),1}=[newPrefix thisPointNumber];
                end
            else
                msgbox('This point will be removed from the group');
                table{row,6}=max([table{:,6}])+1;
            end
            
        end
    end
end

%if there is a change to a group - need to make sure the new entry has the
%same exposure time as all other group members

%If one of the point names has been changed - check if the new name is
%unique - if not display an error dialogue and rever to previous name


set(hObject,'Data',table);
handles.acquisition.points=table;
updateDiskSpace(handles);
guidata(hObject, handles)