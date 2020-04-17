script "Global_Chat_Menu"
--> MetaData
-
license: GPLv3
name: Global_Chat_Menu
type: controller
version: 0.3


--> Global | Chat | Menu
-
on menu_AuthenticateZoom
   zoom_Authenticate
end menu_AuthenticateZoom

on _
end _

on submenu_Telegram
   return "Global | Telegram | Menu"
end submenu_Telegram

on _
end _

on menu_SendMessage
   put lcw_Ask ("What do you want to send?") into someMessage
   
   slack_SendMessage someMessage
   put the result
end menu_SendMessage

on menu_AuthenticateSlack
   slack_Authenticate
end menu_AuthenticateSlack

on _
end _

on submenu_SlackDocs
   return "Docs | Menu"
end submenu_SlackDocs


--> Docs | Menu
-
on menu_BuildingSlackApps mTarget
   launch url "https://api.slack.com/slack-apps"
end menu_BuildingSlackApps

on menu_SlackWebApi mTarget
   launch url "https://api.slack.com/web"
end menu_SlackWebApi

on menu_SlackApiMethods mTarget
   launch url "https://api.slack.com/methods"
end menu_SlackApiMethods
