script "Global | Slack | Channels | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Slack | Channels | Menu
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


--> Global | Slack | Channels | Menu
-
on menu_ColourJoined displayView
   put the view_Data of displayView into channelData
   --
   put slack_ListJoinedChannelNames (channelData) into channelNames
   set the coloured_Lines ["red"] of displayView to channelNames
end menu_ColourJoined

private on _
end _

private on _
end _

on menu_ApiHelp displayView
   launch url "https://api.slack.com/apps/A05HD6U4SCU/general"
end menu_ApiHelp

private on __
end __

on menu_Refresh displayView
   display_SlackChannels displayView
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | Slack | Channels | Menu")
end submenu_Dev

