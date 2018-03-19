script "Global_Telegram_Menu"
--> MetaData
-
license: GPLv3
name: Global_Telegram_Menu
type: controller
version: 0.2

--> Variables
-
constant BaseRestUrl = "https://api.telegram.org/"
constant ApiKey = "bot286681349:AAHr4f5zLrPKEfpHIf5QfZIH9ftCpw8PWHA"


--> Global | Telegram | Menu
-
on menu_FetchLastWebHook
   put telegram_FetchLastWebhook() into lastWebHookArray
   display_Array lastWebHookArray, "telegram_FetchLastWebhook()", "Global | Telegram | Tree | Menu", "Global | Telegram | Line | Menu"
end menu_FetchLastWebHook

on menu_FetchMessageStore
   put url "https://rest.livecode.world/feast/feast_bot/archive_json" into archiveJSON
   put json_ToArray (archiveJSON) into archiveArray
   display_Array archiveArray, "Message Store", "Global | Telegram | Tree | Menu", "Global | Telegram | Line | Menu"
end menu_FetchMessageStore

on _
end _

on menu_CreateWikiPage
   put 5 into howMany
   put "This is a test wiki page created in Telegram." into firstPara
   put fedwiki_ConstructNewPageArray ("Telegram Podcast", firstPara) into pageArray
   
   put telegram_FetchUpdateArray() into updateArray
   put item 2 of the extents of updateArray into lastNum
   put lastNum - howMany into firstNum
   repeat with messageNum = firstNum to lastNum
      put updateArray [messageNum] ["update_id"] into updateID
      put updateArray [messageNum] ["message"] into messageArray
      
      put messageArray ["message_id"] into messageID
      put messageArray ["from"] into fromArray
      put keys (messageArray) into messageArrayKeys
      switch
         case "text" is among the lines of messageArrayKeys
            put messageArray ["text"] into messageText
            fedwiki_AddParagraphToPageArray pageArray, messageText
            break
         case "voice" is among the lines of messageArrayKeys
            put messageArray ["voice"]["file_id"] into fileID
            put messageArray ["voice"]["mime_type"] into mimeType
            
            -- get audio date
            put telegram_FetchVoiceData (fileID) into voiceData
            -- no upload data and get the audioUrl
            put "http://livecode.world/assets/audio/file_0.oga" into audioUrl
            put "Voice recording from Telegram" into audioDescriptionText
            
            fedwiki_AddAudioToPageArray pageArray, audioUrl, audioDescriptionText
            break
         case empty
            breakpoint
         default
            breakpoint
      end switch
      
   end repeat
   
   display_Array pageArray
   
   fedwiki_SetLocalPageArray "Telegram", pageArray
   
   /*
   put json_FromArray (pageArray) into pageJSON
   put fedwiki_LocalPageJsonFile ("Telegram") into wikiPageFile
   put pageJSON into url ("file:" & wikiPageFile)
   */
   
end menu_CreateWikiPage

on _
end _

on menu_Documentation mTarget, whichDoc
   switch whichDoc
      case "Telegram API"
         put "https://core.telegram.org/bots/api#getting-updates" into someRL
         break
      case "Bot Introduction"
         put "https://core.telegram.org/bots" into someRL
         break
      case "Bot Tutorial"
         put "https://fullmeter.com/blog/?p=14" into someRL
         break
   end switch
   launch url someRL
end menu_Documentation

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Telegram | Menu | Props
-

--> Global | Telegram | Menu | Disabled
-

--> Dev | Menu
-
on menu_SetWebHook
   telegram_SetWebHook "https://rest.livecode.world/feast/feast_bot"
   put the result into resultJSON
   display_JSON resultJSON, "feast_bot.lc,telegram_SetWebHook"
end menu_SetWebHook

on menu_DeleteWebHook
   telegram_DeleteWebHook
   put the result into resultJSON
   display_JSON resultJSON, "feast_bot.lc,telegram_SetWebHook"
end menu_DeleteWebHook

on menu_GetWebHook
   put telegram_GetWebHook () into resultJSON
   display_JSON resultJSON, "feast_bot.lc,telegram_GetWebHook()"
end menu_GetWebHook

on _
end _

on menu_GetMe
   put BaseRestUrl & ApiKey & "/getMe" into someURL
   display_TelegramJson someURL
end menu_GetMe

on menu_GetUpdates
   -- put BaseRestUrl & ApiKey & "/getUpdates?offset=0" into someURL
   -- display_TelegramJson someURL
   put lcw_Ask ("Enter an update id to start from...", 322244825) into someOffset
   put telegram_FetchUpdateArray (someOffset) into someArray
   
   display_Array someArray, "File Array", "Global | Telegram | Tree | Menu", "Global | Telegram | Line | Menu"
end menu_GetUpdates

on menu_FedwikiFileList
   put server_FetchFileArray ("fedwiki.org", "root", "~/.wiki/wiki.feast.fm/status/theme/") into fileArray
   display_Array fileArray
end menu_FedwikiFileList

on menu_SendMessage
   -- https://api.telegram.org/bot000000000:AAAAa0aAA_aaA-Aaaa0A0Aa_a0aa0A0AAAA/sendmessage?text=Happy%20Little%20Clouds&chat_id=1111111111
   put lcw_Ask ("A test message.") into someMessage
   telegram_SendMessage someMessage
end menu_SendMessage

on _
end _

on menu_GetFile
   put telegram_FetchFileArray ("AwADBAADYwADH5_gUW89lLBXHqhuAg") into someArray
   display_Array someArray, "File Array", "Global | Telegram | Tree | Menu", "Global | Telegram | Line | Menu"
end menu_GetFile

on menu_TestVoice
   -- https://api.telegram.org/file/bot<token>/<file_path>
   put BaseRestUrl & "file/" & ApiKey & slash & "voice/file_0.oga" into someURL
   put url someURL into someData
   put someURL & CR & CR & someData
end menu_TestVoice
