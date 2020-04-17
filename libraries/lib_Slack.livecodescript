script "lib_Slack"
--> MetaData
-
license: GPLv3
name: lib_Slack
type: library
version: 0.2


--> Variables
-
constant kSlackApiStem = "https://slack.com/api/"


--> Slack
-
command slack_SendMessage someMessage
   /*
   https://slack.com/api/
   chat.postMessage?
   token=xoxp-30525850577-217902599698-222059313280-441ef5dc6448811efab813e7baeb5d43&
   channel=C0WFB754M&
   text=Test%20from%20web%20site.
   &pretty=1
   */
   
   -- put urlencode (someMessage) into someMessage
   put slack_GetAuthToken() into slackAuthToken
   
   -- put kSlackApiStem & "chat.postMessage" into restURL
   
   -- seems like you set up a webhook for a specific channel
   -- put "https://hooks.slack.com/services/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" into restURL -- #fetchh
   put "https://hooks.slack.com/services/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" into restURL -- # General
   
   put someMessage into jsonArray ["text"]
   -- put "C0WFB754M" into jsonArray ["channel"]
   --
   put json_FromArray (jsonArray) into someJSON
   
   -- Content-Type' = 'application/json; charset=UTF-8
   put "Content-type: application/json; charset=UTF-8" & CR & "Authorization: token " & slackAuthToken into oAuthHeaders
   set the httpHeaders to oAuthHeaders
   
   post someJSON to url restURL
   put it into responseJSON
   -- should error check
   
   /*
   put "?" & "token=" & slackAuthToken after restURL
   put "&" & "channel=" & "C0WFB754M" after restURL
   put "&" & "text=" & encodedMessage after restURL
   --
   put "&pretty=1" after restURL
   put url restURL into responseJSON
   */
   
   put responseJSON
   return responseJSON
end slack_SendMessage


--> Slack | Authenticate
-
command slack_Authenticate pSlackClientID, pSlackClientSecret
   constant kAuthURL = "https://slack.com/oauth/authorize"
   constant kTokenURL = "https://slack.com/api/oauth.access"
   constant kScopes = "incoming-webhook"
   constant kLocalHostPort = 54303 -- needs to be set in slack oAuth configuration page
   
   if pSlackClientID is empty then
      put slack_GetClientID() into pSlackClientID
   end if
   if pSlackClientSecret is empty then
      put slack_GetClientSecret() into pSlackClientSecret
   end if
   
   OAuth2 kAuthURL, kTokenURL, pSlackClientID, pSlackClientSecret, kScopes, kLocalHostPort
   if the result is not empty then
      answer error "Not authorized!" 
   else
      local slackAuthArray
      put it into slackAuthArray
      
      display_Array slackAuthArray
      
      -- you now need to store the webhook for the channel
      put slackAuthArray ["incoming_webhook"]["url"] into webHookUrl
      put webHookUrl
      
      put slackAuthArray ["access_token"] into slackAuthToken
      slack_SetAuthToken slackAuthToken
      
      -- let's return a message
      put lcw_Ask ("Send a message to Slack...", "Hello slack") into someMessage
      put someMessage into tMessage ["text"]
      put ArrayToJSON (tMessage) into tMessage
      
      put slack_GetAuthToken() into slackAuthToken
      set the httpHeaders to "Content-type: application/json" & CR & "Authorization: token " & slackAuthToken
      post tMessage to url webHookUrl
   end if
end slack_Authenticate


--> Slack | Tokens
-
function slack_GetAuthToken
   if the environment = "server" then
      put gConfig["slackAuthToken"] into dropBoxAuthToken
   else
      put pref_FetchValue ("slackAuthToken", "rest") into slackAuthToken
   end if
   return slackAuthToken
end slack_GetAuthToken

command slack_SetAuthToken slackAuthToken
   if the environment = "server" then
      -- this is only temporary
      -- need to figure out how best to store configs (maybe a json file)
      rigSetConfigItem "slackAuthToken", slackAuthToken
   else
      pref_SaveValue "slackAuthToken", slackAuthToken, "rest"
   end if
end slack_SetAuthToken

function slack_GetClientID
   if the environment = "server" then
      put gConfig["slackClientID"] into dropBoxAuthToken
   else
      put pref_FetchValue ("slackClientID", "rest") into slackClientID
   end if
   return slackClientID
end slack_GetClientID

command slack_SetClientID slackClientID
   if the environment = "server" then
      -- this is only temporary
      -- need to figure out how best to store configs (maybe a json file)
      rigSetConfigItem "slackClientID", slackClientID
   else
      pref_SaveValue "slackClientID", slackClientID, "rest"
   end if
end slack_SetClientID

function slack_GetClientSecret
   if the environment = "server" then
      put gConfig["slackClientSecret"] into dropBoxAuthToken
   else
      put secret_Get ("slackClientSecret", "rest") into slackClientSecret
      put pref_FetchValue ("slackClientSecret", "rest") into slackClientSecret
   end if
   return slackClientSecret
end slack_GetClientSecret

command slack_SetClientSecret slackClientSecret
   if the environment = "server" then
      -- this is only temporary
      -- need to figure out how best to store configs (maybe a json file)
      -- rigSetConfigItem "slackClientSecret", slackClientSecret
   else
      pref_SaveValue "slackClientSecret", slackClientSecret, "rest"
   end if
end slack_SetClientSecret
