script "Global_Chat_Menu"
--> MetaData
-
license: GPLv3
name: Global_Chat_Menu
type: controller
version: 0.3


--> Global | Chat | Menu
-
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

on menu_SlackDocs mTarget, whichDocs
   switch whichDocs
      case "Building Slack apps"
         launch url "https://api.slack.com/slack-apps"
         break
      case "Slack Web API"
         launch url "https://api.slack.com/web"
         break
      case "Slack API Methods"
         launch url "https://api.slack.com/methods"
         break
   end switch
end menu_SlackDocs


--> Global | Chat | Menu | Props
-

--> Global | Chat | Menu | Disabled
-
