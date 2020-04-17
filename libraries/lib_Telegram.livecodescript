script "lib_Telegram"
--> MetaData
-
license: GPLv3
name: lib_Telegram
type: library
version: 0.1

--> Variables
-
constant BaseRestUrl = "https://api.telegram.org/"

function telegram_GetApiKey
   put secret_Get ("TelegramBotToken") into apiKey
   return apiKey
end telegram_GetApiKey

command telegram_SetApiKey apiKey
   secret_Set "TelegramBotToken", apiKey
end telegram_SetApiKey


--> Display
-
command display_TelegramJson someURL
   put url someURL into someJSON
   -- display_JSON someJSON
   put json_ToArray (someJSON) into someArray
   display_Array someArray
end display_TelegramJson


--> FEAST
-
function telegram_FetchLastWebhook
   put url "https://rest.livecode.world/feast/feast_bot/get_webhook" into lastWebHookJson
   put json_ToArray (lastWebHookJson) into lastWebHookArray
   return lastWebHookArray
end telegram_FetchLastWebhook


--> Telegram
-
function telegram_ConstructDownloadURL filePath
   put telegram_GetApiKey() into TelegramBotToken
   --
   replace space with "%20" in filePath
   url_EncodeItems filePath
   put merge ("https://api.telegram.org/file/[[TelegramBotToken]]/[[filePath]]") into downloadURL
   return downloadURL
end telegram_ConstructDownloadURL

function telegram_FetchAudioArray itemArray
   put itemArray ["update_id"] into updateID
   
   put itemArray ["message"] into messageArray
   --
   put messageArray ["audio"] into audioArray
   put messageArray ["chat"] into chatArray
   put messageArray ["forward_from"] into fromArray
   put messageArray ["from"] into fromArray
   put messageArray ["message_id"] into messageID
   --
   return audioArray
end telegram_FetchAudioArray

command telegram_DeconstructAudioArray audioArray, @fileID, @mimeType, @performerName, @trackTitle
   put audioArray ["file_id"] into fileID
   put audioArray ["mime_type"] into mimeType
   put audioArray ["performer"] into performerName
   put audioArray ["title"] into trackTitle
end telegram_DeconstructAudioArray

function telegram_FetchTemporaryDownloadUrl itemArray
   put telegram_FetchAudioArray (itemArray) into audioArray
   telegram_DeconstructAudioArray audioArray, fileID, mimeType, performerName, trackTitle
   --
   put telegram_FetchFileArray (fileID) into fileArray
   -- put fileArray ["file_id"] into fileID
   put fileArray ["file_path"] into filePath
   put fileArray ["file_size"] into fileSize
   
   put telegram_ConstructDownloadURL (filePath) into downloadURL
   return downloadURL
end telegram_FetchTemporaryDownloadUrl

function telegram_GetWebHook
   put telegram_GetApiKey() into TelegramBotToken
   --
   put BaseRestUrl & TelegramBotToken & "/getWebhookInfo" into someURL
   put url someURL into someResult
   return someResult
end telegram_GetWebHook

command telegram_SetWebHook webhookURL
   put telegram_GetApiKey() into TelegramBotToken
   --
   put BaseRestUrl & TelegramBotToken & "/setWebhook?url=" into someURL
   put urlEncode (webhookURL) after someURL
   put url someURL into someResult
   return someResult
end telegram_SetWebHook

command telegram_DeleteWebHook
   put telegram_GetApiKey() into TelegramBotToken
   --
   put BaseRestUrl & TelegramBotToken & "/deleteWebhook" into someURL
   put url someURL into someResult
   return someResult
end telegram_DeleteWebHook

function telegram_FetchVoiceData fileID
   put telegram_GetApiKey() into TelegramBotToken
   --
   put telegram_FetchFileArray (fileID) into resultArray
   put resultArray ["file_path"] into filePath
   put resultArray ["file_size"] into fileSize
   
   -- https://api.telegram.org/file/bot<token>/<file_path>
   put BaseRestUrl & "file/" & TelegramBotToken & slash & filePath into someURL
   put url someURL into voiceData
   return voiceData
end telegram_FetchVoiceData

command telegram_SendMessage someText, pChatID
   if pChatID is empty then put -176652117 into pChatID
   put telegram_GetApiKey() into TelegramBotToken
   --
   put urlEncode (someText) into encodeText
   
   put BaseRestUrl & TelegramBotToken & "/sendmessage?text=" into someURL
   put encodeText after someURL
   put "&chat_id=" & pChatID after someURL
   
   put url someURL into someResult
   return someResult
end telegram_SendMessage

function telegram_FetchUpdateArray pOffset
   put telegram_GetApiKey() into TelegramBotToken
   --
   if pOffset is not a number then
      put 0 into pOffset
   end if
   put BaseRestUrl & TelegramBotToken & "/getUpdates?offset=" & pOffset into someURL
   put json_FetchArray (someURL) into resultArray
   return resultArray
end telegram_FetchUpdateArray

function telegram_FetchFileArray fileID
   /*
   getFile
   Use this method to get basic info about a file and prepare it for downloading. For the moment, bots can download files of up to 20MB in size. On success, a File object is returned. The file can then be downloaded via the link https://api.telegram.org/file/bot<token>/<file_path>, where <file_path> is taken from the response. It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile again.
   
   Parameters	Type	Required	Description
   file_id	String	Yes	File identifier to get info about
   Note: This function may not preserve the original file name and MIME type. You should save the file's MIME type and name (if available) when the File object is received.
   */
   
   put telegram_GetApiKey() into TelegramBotToken
   --
   put BaseRestUrl & TelegramBotToken & "/getFile?file_id=" & fileID into someURL
   put json_FetchArray (someURL) into someArray
   return someArray
end telegram_FetchFileArray


--> Deps
-
command url_EncodeItems @someURL
   set the itemdelimiter to slash
   repeat with itemNum = 1 to the number of items of someURL
      put urlencode (item itemNum of someURL) into encodedValue
      put encodedValue into item itemNum of someURL
   end repeat
end url_EncodeItems

function json_FetchArray someURL
   put url someURL into someJSON
   put json_ToArray (someJSON) into someArray
   if someArray ["ok"] = true then
      put someArray ["result"] into resultArray
      return resultArray
   else
      return empty
   end if
end json_FetchArray
