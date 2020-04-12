/*
The nPose scripts are licensed under the GPLv2 (http://www.gnu.org/licenses/gpl-2.0.txt), with the following addendum:

The nPose scripts are free to be copied, modified, and redistributed, subject to the following conditions:
    - If you distribute the nPose scripts, you must leave them full perms.
    - If you modify the nPose scripts and distribute the modifications, you must also make your modifications full perms.

"Full perms" means having the modify, copy, and transfer permissions enabled in Second Life and/or other virtual world platforms derived from Second Life (such as OpenSim).  If the platform should allow more fine-grained permissions, then "full perms" will mean the most permissive possible set of permissions allowed by the platform.
*/

integer SEAT_INIT=250;
integer SEAT_UPDATE = 251;//we gonna do satmsg and notsatmsg
integer MEMORY_USAGE = 34334;
integer OPTIONS = -240;
integer DO = 220;

integer SATNOTSAT_PLUGIN=-520;
integer SATNOTSAT_REFRESH=-521;
integer TIMER_ADD=-600;
integer TIMER_REMOVE=-601;

//generic message numbers
integer ON_ENTER=-700; //triggers if someone enters a slot. Reported data: seatNumber and avatarUUID
integer ON_EXIT=-701; //triggers if someone leaves a slot. Reported data: seatNumber and avatarUUID
integer ON_NEW=-702; //triggers if someone sits on the object. Reported data: seatNumber and avatarUUID
integer ON_CHANGE=-703; //triggers if someone changed the slot. Reported data: oldSeattNumber, newSeatNumber and avatarUUID
integer ON_LOST=-704; //triggers if someone unsits from the object. Reported data: seatNumber and avatarUUID
integer ON_ALL_EMPTY=-705; //triggers if the Slots list was not empty but is empty now.
integer ON_ALL_NOT_EMPTY=-706; //triggers if the Slots list was empty but is not empty anymore.
integer ON_ALL_FULL=-707; //triggers if the Slots list was not full but is full now.
integer ON_ALL_NOT_FULL=-708; //triggers if the Slots list was full but is not full anymore.
integer ON_INVALID=-719; //there is no valid Slots list

//generic event report has to be activated
//once activated it can't be deactivated
integer ENABLE_EVENT_ON_ENTER=0x1;
integer ENABLE_EVENT_ON_EXIT=0x2;
integer ENABLE_EVENT_ON_NEW=0x4;
integer ENABLE_EVENT_ON_CHANGE=0x8;
integer ENABLE_EVENT_ON_LOST=0x10;
integer ENABLE_EVENT_ON_ALL_EMPTY=0x20;
integer ENABLE_EVENT_ON_ALL_NOT_EMPTY=0x40;
integer ENABLE_EVENT_ON_ALL_FULL=0x80;
integer ENABLE_EVENT_ON_ALL_NOT_FULL=0x100;
integer ENABLE_EVENT_ON_INVALID=0x80000000;
integer EnabledEvents;

integer SITTER_TYPE_NONE=0;
integer SITTER_TYPE_AVATAR=1;
integer SITTER_TYPE_BUDDY=2;

integer SLOTS_SEAT_NAME=0;
integer SLOTS_SEAT_PERM=1;
integer SLOTS_ANIM_NAMES=2;
integer SLOTS_ANIM_POS=3;
integer SLOTS_ANIM_ROT=4;
integer SLOTS_FACIALS=5;
integer SLOTS_ANIM_NC_NAME=6;
integer SLOTS_ANIM_COMMAND=7;
integer SLOTS_SITTER_KEY=8;
integer SLOTS_SITTER_TYPE=9;
integer SLOTS_SITTER_NAME=10;

integer SlotsStride;
integer SlotsCount;

list SlotsSitterType;
list SlotsSitterKey; 
list MsgOnSit;
list MsgOnUnSit;
list MsgOnEnter;
list MsgOnExit;
list MsgOnNew;
list MsgOnLost;

list EmptyMsgList; //a list with as many blank string elements as the number of slots

list StoredMsgOnUnSit;
//list StoredMsgOnExit;
//list StoredMsgOnLost;

string MsgOnAllEmpty;
string MsgOnAllNotEmpty;
string MsgOnAllFull;
string MsgOnAllNotFull;

list TimerList; //float trigger time based on llGetTime, user defined string, user defined key

string NC_READER_CONTENT_SEPARATOR="%&§";
integer OptionSitterType=SITTER_TYPE_AVATAR;


debug(list message){
    llOwnerSay((((llGetScriptName() + "\n##########\n#>") + llDumpList2String(message,"\n#>")) + "\n##########"));
}

onEnter(key avatar, integer slotNumber) {
    if(EnabledEvents & ENABLE_EVENT_ON_ENTER) {
        llMessageLinked(LINK_SET, ON_ENTER, (string)(slotNumber+1), avatar);
    }
    sendUserDefinedMessage(avatar, llList2String(MsgOnEnter, slotNumber));
}
onExit(key avatar, integer slotNumber) {
    if(EnabledEvents & ENABLE_EVENT_ON_EXIT) {
        llMessageLinked(LINK_SET, ON_EXIT, (string)(slotNumber+1), avatar);
    }
    sendUserDefinedMessage(avatar, llList2String(MsgOnExit, slotNumber));
}
onNew(key avatar, integer slotNumber) {
    if(EnabledEvents & ENABLE_EVENT_ON_NEW) {
        llMessageLinked(LINK_SET, ON_NEW, (string)(slotNumber+1), avatar);
    }
    sendUserDefinedMessage(avatar, llList2String(MsgOnNew, slotNumber));
}
onChange(key avatar, integer oldSlotNumber, integer newSlotNumber) {
    if(EnabledEvents & ENABLE_EVENT_ON_CHANGE) {
        llMessageLinked(LINK_SET, ON_CHANGE, (string)(oldSlotNumber+1) + "," + (string)(newSlotNumber+1), avatar);
    }
}
onLost(key avatar, integer slotNumber) {
    if(EnabledEvents & ENABLE_EVENT_ON_LOST) {
        llMessageLinked(LINK_SET, ON_LOST, (string)(slotNumber+1), avatar);
    }
    sendUserDefinedMessage(avatar, llList2String(MsgOnLost, slotNumber));
}
onAllEmpty() {
    if(EnabledEvents & ENABLE_EVENT_ON_ALL_EMPTY) {
        llMessageLinked(LINK_SET, ON_ALL_EMPTY, "", NULL_KEY);
    }
    sendUserDefinedMessage(NULL_KEY, MsgOnAllEmpty);
}
onAllNotEmpty() {
    if(EnabledEvents & ENABLE_EVENT_ON_ALL_NOT_EMPTY) {
        llMessageLinked(LINK_SET, ON_ALL_NOT_EMPTY, "", NULL_KEY);
    }
    sendUserDefinedMessage(NULL_KEY, MsgOnAllNotEmpty);
}
onAllFull() {
    if(EnabledEvents & ENABLE_EVENT_ON_ALL_FULL) {
        llMessageLinked(LINK_SET, ON_ALL_FULL, "", NULL_KEY);
    }
    sendUserDefinedMessage(NULL_KEY, MsgOnAllFull);
}
onAllNotFull() {
    if(EnabledEvents & ENABLE_EVENT_ON_ALL_NOT_FULL) {
        llMessageLinked(LINK_SET, ON_ALL_NOT_FULL, "", NULL_KEY);
    }
    sendUserDefinedMessage(NULL_KEY, MsgOnAllNotFull);
}
onInvalid() {
    if(EnabledEvents & ENABLE_EVENT_ON_INVALID) {
        llMessageLinked(LINK_SET, ON_INVALID, "", NULL_KEY);
    }
}
onSit(key avatar, integer slotNumber) {
    sendUserDefinedMessage(avatar, llList2String(MsgOnSit, slotNumber));
    StoredMsgOnUnSit=llListReplaceList(StoredMsgOnUnSit, (list)llList2String(MsgOnUnSit, slotNumber), slotNumber, slotNumber);
}
onUnSit(key avatar, integer slotNumber) {
    sendUserDefinedMessage(avatar, llList2String(StoredMsgOnUnSit, slotNumber));
    StoredMsgOnUnSit=llListReplaceList(StoredMsgOnUnSit, (list)"", slotNumber, slotNumber);
}

sendUserDefinedMessage(key avatar, string msg) {
    if(msg) {
        llMessageLinked(LINK_SET, DO, msg, avatar);
    }
}

checkTimer() {
    llSetTimerEvent(0.0);
    float timerTime;
    float timeNow=llGetTime();
    while(timerTime<=0.01 && llGetListLength(TimerList)) {
        timerTime=llList2Float(TimerList, 0) - timeNow;
        if(timerTime<=0.01) {
            llMessageLinked(LINK_SET, DO, llList2String(TimerList, 2), llList2Key(TimerList, 3));
            TimerList=llDeleteSubList(TimerList, 0, 3);
        }
    }
    if(llGetListLength(TimerList)) {
        llSetTimerEvent(timerTime);
    }
}

default {
    link_message(integer sender_num, integer num, string str, key id) {
        if(num==TIMER_ADD) {
            list parts=llParseStringKeepNulls(str, ["|"], []);
            string name=llToLower(llStringTrim(llList2String(parts, 0), STRING_TRIM));
            list times=llCSV2List(llList2String(parts, 1));
            string command=llDumpList2String(llDeleteSubList(parts, 0, 1), "|");
            while(llGetListLength(times)) {
                string timeString=llList2String(times, 0);
                float time=(float)timeString;
                times=llDeleteSubList(times, 0, 0);
                if(llToLower(llGetSubString(timeString, 0, 0))=="r") {
                    time=(float)llList2String(times, 0) + llFrand((float)llList2String(times, 1) - (float)llList2String(times, 0));
                    times=llDeleteSubList(times, 0, 1);
                }
                TimerList+=[
                    llGetTime() + time,
                    name,
                    command,
                    id
                ];
            }
            if(llGetListLength(TimerList)>4) {
                TimerList=llListSort(TimerList, 4, TRUE);
            }
            //check and set the timer
            checkTimer();
        }
        else if(num==TIMER_REMOVE) {
            str=llToLower(llStringTrim(str, STRING_TRIM));
            if (str=="" || str=="*") {
                TimerList=[];
            }
            else {
                list timerRemoveList=llCSV2List(str);
                integer timerRemoveListLength=llGetListLength(timerRemoveList);
                integer timerNamesIndex;
                integer timerNamesLength=llGetListLength(TimerList);
                while(timerNamesIndex<timerNamesLength) {
                    string timerName=llList2String(TimerList, timerNamesIndex+1);
                    integer timerRemoveListIndex;
                    integer match;
                    while(!match && timerRemoveListIndex<timerRemoveListLength) {
                        string timerRemoveName=llList2String(timerRemoveList, timerRemoveListIndex);
                        if(llGetSubString(timerRemoveName, -1, -1)=="*") {
                            match=!llSubStringIndex(timerName, llDeleteSubString(timerRemoveName, -1, -1));
                        }
                        else {
                            match=timerRemoveName==timerName;
                        }
                        timerRemoveListIndex++;
                    }
                    if(match) {
                        TimerList=llDeleteSubList(TimerList, timerNamesIndex, timerNamesIndex+3);
                        timerNamesLength-=4;
                    }
                    else {
                        timerNamesIndex+=4;
                    }
                }
            }
            //check and set the timer
            checkTimer();
        }
        else if(num==SEAT_INIT) {
            //initialize the other lists
            SlotsCount=(integer)str;
            integer index;
            EmptyMsgList=[];
            for(index=0; index<SlotsCount; index++) {
                EmptyMsgList+=(list)"";
            }
            //this will clear the ON_X commands
            MsgOnSit=MsgOnUnSit=MsgOnEnter=MsgOnExit=MsgOnNew=MsgOnLost=StoredMsgOnUnSit=EmptyMsgList;
            MsgOnAllEmpty=MsgOnAllNotEmpty=MsgOnAllFull=MsgOnAllNotFull="";
        }
//        else if(num==SATNOTSAT_REFRESH) {
//            MsgOnUnSit=NewMsgOnUnSit;
//            NewMsgOnUnSit=EmptyMsgList;
//        }
        else if(num==SATNOTSAT_PLUGIN) {
            list commandList=llParseString2List(str, [NC_READER_CONTENT_SEPARATOR], []);
            str="";
            while(commandList) {
                string commandLine=llList2String(commandList, 0);
                commandList=llDeleteSubList(commandList, 0, 0);
                list parts=llParseStringKeepNulls(commandLine, ["|"], []);
                string action=llList2String(parts, 0);
                
                string msg=llDumpList2String(llDeleteSubList(parts, 0, 0), "|");
                if(action=="ON_ALL_EMPTY") {MsgOnAllEmpty=msg;}
                else if(action=="ON_ALL_NOT_EMPTY") {MsgOnAllNotEmpty=msg;}
                else if(action=="ON_ALL_FULL") {MsgOnAllFull=msg;}
                else if(action=="ON_ALL_NOT_FULL") {MsgOnAllNotFull=msg;}
                else {
                    //all commands with seatNumbers as first parameter
                    list seatNumberList=llCSV2List(llList2String(parts, 1));
                    if(llList2String(parts, 1)=="*") {
                        seatNumberList=[];
                        integer seatNumber;
                        for(seatNumber=1; seatNumber<=SlotsCount; seatNumber++) {
                            seatNumberList+=(string)seatNumber;
                        }
                    }
                    //NEW Syntax: ON_X|csv seatNumbers or *|any command ...
                    msg=llDumpList2String(llDeleteSubList(parts, 0, 1), "|");
                    while(seatNumberList) {
                        integer slotNumber=(integer)llList2String(seatNumberList, 0) - 1;
                        seatNumberList=llDeleteSubList(seatNumberList, 0, 0);
                        if(slotNumber>=0 && slotNumber<SlotsCount) {
                            //you are allowed to use multiple ON_(UN)SIT commands with the same seat number in one NC
                            //a ON_(UN)SIT without the command part will clear the commands for that seat 
                            if(action=="ON_SIT") {
                                string newMsg;
                                if(msg) {
                                    newMsg=llDumpList2String(llParseString2List(llList2String(MsgOnSit, slotNumber), [NC_READER_CONTENT_SEPARATOR], []) + (list)msg, NC_READER_CONTENT_SEPARATOR);
                                }
                                MsgOnSit=llListReplaceList(MsgOnSit, (list)newMsg, slotNumber, slotNumber);
                            }
                            else if(action=="ON_UNSIT") {
                                string newMsg;
                                if(msg) {
                                    newMsg=llDumpList2String(llParseString2List(llList2String(MsgOnUnSit, slotNumber), [NC_READER_CONTENT_SEPARATOR], []) + (list)msg, NC_READER_CONTENT_SEPARATOR);
                                }
                                MsgOnUnSit=llListReplaceList(MsgOnUnSit, (list)newMsg, slotNumber, slotNumber);
                            }
                            else if(action=="ON_ENTER") {
                                string newMsg;
                                if(msg) {
                                    newMsg=llDumpList2String(llParseString2List(llList2String(MsgOnEnter, slotNumber), [NC_READER_CONTENT_SEPARATOR], []) + (list)msg, NC_READER_CONTENT_SEPARATOR);
                                }
                                MsgOnEnter=llListReplaceList(MsgOnEnter, (list)newMsg, slotNumber, slotNumber);
                            }
                            else if(action=="ON_EXIT") {
                                string newMsg;
                                if(msg) {
                                    newMsg=llDumpList2String(llParseString2List(llList2String(MsgOnExit, slotNumber), [NC_READER_CONTENT_SEPARATOR], []) + (list)msg, NC_READER_CONTENT_SEPARATOR);
                                }
                                MsgOnExit=llListReplaceList(MsgOnExit, (list)newMsg, slotNumber, slotNumber);
                            }
                            else if(action=="ON_NEW") {
                                string newMsg;
                                if(msg) {
                                    newMsg=llDumpList2String(llParseString2List(llList2String(MsgOnNew, slotNumber), [NC_READER_CONTENT_SEPARATOR], []) + (list)msg, NC_READER_CONTENT_SEPARATOR);
                                }
                                MsgOnNew=llListReplaceList(MsgOnNew, (list)newMsg, slotNumber, slotNumber);
                            }
                            else if(action=="ON_LOST") {
                                string newMsg;
                                if(msg) {
                                    newMsg=llDumpList2String(llParseString2List(llList2String(MsgOnLost, slotNumber), [NC_READER_CONTENT_SEPARATOR], []) + (list)msg, NC_READER_CONTENT_SEPARATOR);
                                }
                                MsgOnLost=llListReplaceList(MsgOnLost, (list)newMsg, slotNumber, slotNumber);
                            }
                        }
                    }
                }
            }
        }
        else if(num==SEAT_UPDATE) {
            //get avatars from Slots list

            list slots = llParseStringKeepNulls(str, ["^"], []);
            str="";
            SlotsStride=(integer)llList2String(slots, 0);
            integer preambleLength=(integer)llList2String(slots, 1);
            list changedAnimations=llParseString2List(llList2String(slots, 2), [","], []);
            slots=llDeleteSubList(slots, 0, preambleLength-1);

            list oldSlotsSitterKey=SlotsSitterKey;
            SlotsSitterKey=[];
            list oldSlotsSitterType=SlotsSitterType;
            SlotsSitterType=[];

            integer index;
            integer length=llGetListLength(slots);
            for(index=0; index<length; index+=SlotsStride) {
                SlotsSitterKey+=llList2String(slots, index + SLOTS_SITTER_KEY);
                SlotsSitterType+=(integer)llList2String(slots, index + SLOTS_SITTER_TYPE);
            }

            //check if someone leaves a slot
            //check for ON_UNSIT
            //check if we lost sitter
            length=llGetListLength(oldSlotsSitterType);
            integer oldEmpty=TRUE;
            integer oldFull=TRUE;
            for(index=0; index<length; index++) {
                integer oldSitterType=llList2Integer(oldSlotsSitterType, index);
                if(oldSitterType & OptionSitterType) {
                    oldEmpty=FALSE;
                    string oldSitterKey=llList2String(oldSlotsSitterKey, index);
                    string sitterKey=llList2String(SlotsSitterKey, index);
                    if(oldSitterKey!=sitterKey) {
                        //this avatar leaves a slot
                        onExit((key)oldSitterKey, index);
                        if(!~llListFindList(SlotsSitterKey, [oldSitterKey])) {
                            //we lost this avatar
                            onLost((key)oldSitterKey, index);
                        }
                    }
                    //ON_UNSIT detection
                    if(oldSitterKey!=sitterKey || ~llListFindList(changedAnimations, [(string)index])) {
                        onUnSit((key)oldSitterKey, index);
                    }
                }
                else {
                    oldFull=FALSE;
                }
            }
            //check if someone enters a slot
            //check for ON_SIT
            //check if we have a new sitter
            //check if someone changed the slot
            length=llGetListLength(SlotsSitterType);
            integer empty=TRUE;
            integer full=TRUE;
            for(index=0; index<length; index++) {
                integer sitterType=llList2Integer(SlotsSitterType, index);
                if(sitterType & OptionSitterType) {
                    empty=FALSE;
                    string oldSitterKey=llList2String(oldSlotsSitterKey, index);
                    string sitterKey=llList2String(SlotsSitterKey, index);
                    if(sitterKey!=oldSitterKey) {
                        //this avatar enters a slot
                        onEnter((key)sitterKey, index);
                        integer oldSlot=llListFindList(oldSlotsSitterKey, [sitterKey]);
                        if(~oldSlot) {
                            //this avatar changed the slot
                            onChange((key)sitterKey, oldSlot, index);
                        }
                        else {
                            //we have a new sitter
                            onNew((key)sitterKey, index);
                        }
                    }
                    //ON_SIT detection
                    if(oldSitterKey!=sitterKey || ~llListFindList(changedAnimations, [(string)index])) {
                        onSit((key)sitterKey, index);
                    }
                }
                else {
                    full=FALSE;
                }
            }
            if(empty && full) {
                //invalid slot list
                onInvalid();
            }
            else {
                if(empty && !oldEmpty) {
                    //changed to empty
                    onAllEmpty();
                }
                if(!empty && oldEmpty) {
                    //changed to not empty
                    onAllNotEmpty();
                }
                if(full && !oldFull) {
                    //changed to full
                    onAllFull();
                }
                if(!full && oldFull) {
                    //changed to not full
                    onAllNotFull();
                }
            }
        }
        else if(num == OPTIONS) {
            //save new option(s) or macro(s) or userdefined permissions from LINKMSG
            list optionsToSet = llParseStringKeepNulls(str, ["~","|"], []);
            integer length = llGetListLength(optionsToSet);
            integer index;
            for(index=0; index<length; ++index) {
                list optionsItems = llParseString2List(llList2String(optionsToSet, index), ["="], []);
                string optionItem = llToLower(llStringTrim(llList2String(optionsItems, 0), STRING_TRIM));
                string optionString = llList2String(optionsItems, 1);
                string optionSetting = llToLower(llStringTrim(optionString, STRING_TRIM));
                integer optionSettingFlag = optionSetting=="on" || (integer)optionSetting;

                if(optionItem == "enableevents") {EnabledEvents = EnabledEvents | (integer)optionSetting;}
                if(optionItem == "eventsittertype") {OptionSitterType = (integer)optionSetting;}
            }
        }
        else if(num == MEMORY_USAGE) {
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit()
             + ", Leaving " + (string)llGetFreeMemory() + " memory free.");
        }
    }
    on_rez(integer params) {
        llResetScript();
    }
    timer() {
        checkTimer();
    }
}
