script "lib_Zoom"
--> MetaData
-
license: GPLv3
name: lib_Zoom
type: library
version: 0.1


/*
Compare with "lib_DisplayGraph"
*/

--> Zoom | Authenticate
-
command zoom_Authenticate pClientID, pClientSecret
   -- https://marketplace.zoom.us/docs/guides/auth/oauth
   -- OAuth2 endpoints are located at https://zoom.us/oauth/
   
   -- https://zoom.us/oauth/authorize?response_type=code&client_id=7lstjK9NTyett_oeXtFiEQ&redirect_uri=https://yourapp.com
   
   
   constant kAuthURL = "https://zoom.us/oauth/authorize"
   constant kTokenURL = "https://zoom.us/oauth/token"
   local kScopes
   local kLocalHostPort
   
   if pClientID is empty then
      put zoom_GetApiKey() into pClientID
   end if
   if pClientSecret is empty then
      put zoom_GetApiSecret() into pClientSecret
   end if
   
   OAuth2 kAuthURL, kTokenURL, pClientID, pClientSecret, kScopes, kLocalHostPort
   if the result is not empty then
      answer error "Not authorized!" 
   else
      put it into zoomAuthArray
      --
      display_Array zoomAuthArray
   end if
end zoom_Authenticate

function zoom_GetApiKey
   put secret_Get ("zoomApiKey") into apiKey
   return apiKey
end zoom_GetApiKey

command zoom_SetApiKey apiKey
   secret_Set "zoomApiKey", apiKey
end zoom_SetApiKey

function zoom_GetJWT
   -- test token that lasts for one week
   put secret_Get ("zoomJWT") into zoomJWT
   return zoomJWT
end zoom_GetJWT

function zoom_GetApiSecret
   put secret_Get ("zoomApiSecret") into apiSecret
   return apiSecret
end zoom_GetApiSecret

command zoom_SetApiSecret apiSecret
   secret_Set "zoomApiSecret", apiSecret
end zoom_SetApiSecret

command zoom_SetJWT zoomJWT
   secret_Set "zoomJWT", zoomJWT
end zoom_SetJWT


--> Zoom
-
command zoom_Test
   put zoom_FetchUserMeetings() into someJSON
   --
   display_Json someJSON, "Zoom"
end zoom_Test

function zoom_FetchUserMeetings userName
   put zoom_GetUserID (userName) into userId
   put merge ("users/[[userId]]/meetings") into restPath
   put zoom_Fetch (restPath) into someJSON
   return someJSON
end zoom_FetchUserMeetings

function zoom_FetchUser userName
   put zoom_GetUserID (userName) into userId
   put merge ("https://api.zoom.us/v2/users/[[userId]]") into restURL
   put zoom_GetRest (restURL) into someJSON
   return someJSON
end zoom_FetchUser

function zoom_ListAccountUsers
   /*
   curl --request GET \
   --url 'https://api.zoom.us/v2/users?page_number=1&page_size=30&status=active' \
   --header 'authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6ImVpZ0stdUpBUk95XzFRVF9qMFFia0EiLCJleHAiOjE1ODY0NjEyODEsImlhdCI6MTU4NTg1NjQ4MX0.sgaIUmk3B1RKgproF0Lay-USQy86_HHQ_1tBvT2c5hs'
   */
   
   put "https://api.zoom.us/v2/users?page_number=1&page_size=30&status=active" into restURL
   put zoom_GetRest (restURL) into someJSON
   return someJSON
end zoom_ListAccountUsers

function zoom_GetUserID userName
   return "lYZzjYApSMqr6YPh-3Ma5g"
end zoom_GetUserID

function zoom_Fetch restPath
   put "https://api.zoom.us/v2/" into apiStem
   put apiStem & restPath into restURL
   put zoom_GetRest (restURL) into someJSON
   return someJSON
end zoom_Fetch

function zoom_GetRest restURL
   put zoom_GetJWT() into jwtToken
   put jsonrpc_GET (restURL, jwtToken) into someJSON
   return someJSON
end zoom_GetRest
