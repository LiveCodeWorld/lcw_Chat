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
command slack_ChannelDataSetJoined @channelData, conversationID, sBoolean
   put indexArray_Find (channelData, "id", conversationID) into indexNum
   put sBoolean into channelData [indexNum]["is_member"]
   return indexNum
end slack_ChannelDataSetJoined

function slack_BotJoinedChannel chanelName, channelData
   put indexArray_GetNamed (channelData, chanelName, "is_member") into isMember
   return isMember
end slack_BotJoinedChannel

function slack_ListJoinedChannelNames channelData
   repeat with indexNum = 1 to item 2 of the extents of channelData
      put channelData [indexNum]["is_member"] into isMember
      if isMember is true then
         put channelData [indexNum]["name"] & CR after joinedNames
      end if
   end repeat
   delete char -1 of joinedNames
   return joinedNames
end slack_ListJoinedChannelNames


--> Slack | Display
-
on mDoubleUp_SlackChannels displayView, channelName
   put the view_Data of displayView into channelData
   put indexArray_GetNamed (channelData, channelName, "id") into channelID
   --
   display_SlackConversation channelID
end mDoubleUp_SlackChannels

on mDoubleUp_SlackConversation displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_SlackConversation

command display_SlackChannels pDisplayView
   -- put "?limit=20&types=public_channel&pretty=1" into pAfterBit
   put slack_ListConversations() into rArray
   
   ## Check response
   if rArray ["ok"] is not true then
      breakpoint
      exit to top
   end if
   
   ## Display Channels
   put rArray ["channels"] into channelData
   -- display_IndexArray channelData, "Channels", "Slack", true
   
   ## Display Channel Names
   display_SlackChannelData channelData, pDisplayView
   put the result into displayView
   --
   display_SetMouseAndMenu displayView, "Slack | Channels", "lib_Slack"
   return displayView
end display_SlackChannels

command display_SlackChannelData channelData, pDisplayView
   lock screen
   put indexArray_List (channelData) into channelNames
   --
   display_Data channelNames, "Channels", "Slack", pDisplayView
   put the result into displayView
   set the view_Data of displayView to channelData
   --
   put slack_ListJoinedChannelNames (channelData) into joinedNames
   set the coloured_Lines ["red"] of displayView to joinedNames
   unlock screen
   
   return displayView
end display_SlackChannelData

command display_SlackConversation conversationID, pDisplayView, pAfterBit
   put slack_GetConversationHistory (conversationID, pAfterBit) into rArray
   -- display_Data rArray, conversationID, "Slack Conversation"
   
   ## Check response
   if rArray ["ok"] is not true then
      breakpoint
      exit to top
   end if
   
   ## Display Channels
   put rArray ["messages"] into indexArray
   --
   display_IndexArray indexArray, "Messages", "Slack", true, "text", pDisplayView
   put the result into displayView
   display_SetMouseAndMenu displayView, "Slack | Conversation", "lib_Slack"
   return displayView
end display_SlackConversation


--> Slack
-
command slack_JoinChannel conversationID
   put conversationID into postArray ["channel"]
   put _PostAndReturn (postArray, "conversations.join") into rArray
   return rArray
end slack_JoinChannel

command slack_LeaveChannel conversationID
   put conversationID into postArray ["channel"]
   return _PostAndReturn (postArray, "conversations.leave")
end slack_LeaveChannel

function slack_GetConversationHistory conversationID, pAfterBit
   put conversationID into postArray ["channel"]
   return _PostAndReturn (postArray, "conversations.history", pAfterBit)
end slack_GetConversationHistory

function slack_ListConversations pAfterBit
   return _GetRestArray ("conversations.list", pAfterBit)
end slack_ListConversations

command slack_SendMessage someMessage, conversationID
   put someMessage into postArray ["text"]
   put conversationID into postArray ["channel"]
   --
   return _PostAndReturn (postArray, "chat.postMessage")
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
      put gConfig["slackClientID"] into slackClientID
   else
      put pref_FetchValue ("slackClientID", "rest") into slackClientID
   end if
   return slackClientID
end slack_GetClientID

command slack_SetClientID slackClientID
   if the environment = "server" then
      -- need to figure out how best to store configs (maybe a json file)
      rigSetConfigItem "slackClientID", slackClientID
   else
      -- secret_Set "slackClientID", slackClientID
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


--> Private
-
private function _PostAndReturn postData, apiBit, pAfterBit
   put _ConstructRestURL (apiBit, pAfterBit) into restURL
   put slack_GetAuthToken() into slackAuthToken
   --
   return jsonrpc_PostArray (postData, restUrl, slackAuthToken)
end _PostAndReturn

private function _GetRestArray apiBit, pAfterBit
   put _ConstructRestURL (apiBit, pAfterBit) into restURL
   put slack_GetAuthToken() into slackAuthToken
   put jsonrpc_GetArray (restURL, slackAuthToken) into rArray
   return rArray
end _GetRestArray

private function _ConstructRestURL apiBit, pAfterBit
   put kSlackApiStem & apiBit into restURL
   put pAfterBit after restURL
   return restURL
end _ConstructRestURL


--> Deps
-
-- function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get
