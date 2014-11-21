function STATE = protocol_update_state( cmdMSP, inBuf, STATE, BOARD )
%PROTOCOL_UPDATE_STATE

[DEF_VAL DEF_STRING DEF_SIZE] = protocol_import_DEF();

byte_counter = 1;
for i=1:DEF_SIZE
    ID = DEF_VAL(i,1);
    if(ID == cmdMSP)
        ITEM = DEF_VAL(i,2);
        if(ITEM == 0)
           %Save the command name
           CELL_IDENT = DEF_STRING{i,1};
        else
           %Get the value to save
           VALUE_IDENT = DEF_STRING{i,1};
           TYPE = DEF_STRING{i,4};
           SCALING = DEF_VAL(i,10);
           if(SCALING == 0)
            SCALING = 1;
           end
           DIGITS = DEF_VAL(i,11);
           Value = 0;
           if(strcmp(TYPE,'uint16')||strcmp(TYPE,'int16'))
               len = 2;
           else
                if(strcmp(TYPE,'uint8')||strcmp(TYPE,'int8'))
                    len = 1;
                else
                    error('Unspecified datatype, protocol_update_state.m');
                end
           end
           try
              Value = typecast(inBuf(byte_counter:byte_counter+len-1),TYPE);
            catch e
              disp(strcat('Expecting more incoming data (file protocol_update_state.m)',32,e.message));
           end
           Value = SCALING*double(Value);
           Value = round(Value*10^DIGITS)/10^DIGITS;
           byte_counter = byte_counter + len;
           EVAL_STR = strcat('STATE.',BOARD,'.',CELL_IDENT,'.',VALUE_IDENT,'=Value;');
           eval(EVAL_STR); %Save into state variable.
        end
        
    end
end