script "Global | Slack | Channels | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Slack | Channels | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

private function _SelectedConversationID displayView
   put _SelectedChannelName (displayView) into chanelName
   put the view_Data of displayView into channelData
   --
   put indexArray_GetNamed (channelData, chanelName, "id") into conversationID
   return conversationID
end _SelectedConversationID

private function _SelectedChannelName displayView
   if the array_View of displayView is empty then
      put the selected_Line of displayView into chanelName
   else
      put the selected_Value of displayView into chanelName
   end if
   return chanelName
end _SelectedChannelName

private function _CheckJoined displayView
   put _SelectedChannelName (displayView) into chanelName
   put the view_Data of displayView into channelData
   --
   put slack_BotJoinedChannel (chanelName, channelData) into botJoined
   return botJoined
end _CheckJoined

private command _Setjoined displayView, conversationID, sBoolean
   put the view_Data of displayView into channelData
   --
   slack_ChannelDataSetJoined channelData, conversationID, sBoolean
   --
   set the view_Data of displayView to channelData
   return channelData
end _Setjoined

private command _SetChannelArray displayView, conversationID, channelArray
   put the view_Data of displayView into channelData
   --
   put indexArray_Find (channelData, "id", conversationID) into indexNum
   put channelArray into channelData [indexNum]
   --
   set the view_Data of displayView to channelData
   return channelData
end _SetChannelArray

getprop checked_Join [displayView]
   return _CheckJoined (displayView)
end checked_Join


--> Global | Slack | Channels | Line | Menu
-
on menu_SendMessage displayView
   put _SelectedConversationID (displayView) into conversationID
   --
   put lcw_Ask ("Enter a mesage to send...") into someMessage
   slack_SendMessage someMessage, conversationID
   put the result into rArray
   if rArray ["ok"] is not true then
      breakpoint
   else
      display_Data rArray
   end if
end menu_SendMessage

on menu_Join displayView
   put _SelectedConversationID (displayView) into conversationID
   --
   if _CheckJoined (displayView) then
      slack_LeaveChannel conversationID
      put the result into jArray
      --
      if jArray ["ok"] is true then
         put the view_Data of displayView into channelData
         slack_ChannelDataSetJoined channelData, conversationID, false
         set the view_Data of displayView to channelData
      else
         breakpoint
         return false
      end if
   else
      slack_JoinChannel conversationID
      put the result into jArray
      --
      if jArray ["ok"] is true then
         put jArray ["channel"] into channelArray
         _SetChannelArray displayView, conversationID, channelArray
         put the result into channelData
      else
         breakpoint
         return false
      end if
   end if
   --
   -- display_Data jArray
   display_SlackChannelData channelData, displayView
end menu_Join

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Slack | Channels | Line | Menu"
end menu_MenuEdit

on submenu_Dev
   return menu_DevTitle ("Global | Slack | Channels | Line | Menu")
end submenu_Dev

