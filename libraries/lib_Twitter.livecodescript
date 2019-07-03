script "lib_Twitter"
--> MetaData
-
license: GPLv3
name: lib_Twitter
type: library
version: 0.1


--> Twitter
-
function twitter_FetchPageJson tweetURL
   -- put "https://twitter.com/Interior/status/507185938620219395" into tweetURL
   put twitter_FetchEmbedHtml (tweetURL) into blockquoteHTML
   --
   put "Imported Tweet" into pageTitle
   put "Here is a tweet imported from [[Twitter]]. Drag and drop into onto your desired page." into firstParagraph
   put fedwiki_ConstructNewPageArray (pageTitle, firstParagraph) into pageArray
   pageArray_AddHtml pageArray, blockquoteHTML
   --
   put json_FromArray (pageArray) into pageJSON
   return pageJSON
end twitter_FetchPageJson
   
function twitter_FetchEmbedHtml tweetURL
   put twitter_FetchOembed (tweetURL) into resultArray
   put resultArray ["html"] into blockquoteHTML
   put resultArray ["url"] into tweetURL
   return blockquoteHTML
end twitter_FetchEmbedHtml

function twitter_FetchOembed tweetURL   
   put twitter_FetchOembedJson (tweetURL) into someJSON
   put json_ToArray (someJSON) into resultArray
   return resultArray
end twitter_FetchOembed

function twitter_FetchOembedJson tweetURL
   put "https://publish.twitter.com/oembed?url=" & urlencode (tweetURL) into someURL
   put url someURL into someJSON
   return someJSON
end twitter_FetchOembedJson

function twitter_FetchTweet
   -- GET https://api.twitter.com/1.1/statuses/show.json?id=210462857140252672
   
end twitter_FetchTweet


