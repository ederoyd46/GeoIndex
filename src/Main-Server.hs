{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Search
import System.Environment (getArgs)
import System.Exit (exitFailure)
import System.IO (hPutStrLn, stderr)
import Control.Monad.State
import           Data.ProtocolBuffers (getField)
import qualified Data.Text            as T
import           Proto
import qualified Data.ByteString.Char8      as B

import Snap.Core
import Snap.Http.Server

import qualified JSONEntry as JSON
import qualified Data.Aeson as JSON (encode)
import Data.Map (fromList)

site :: Snap ()
site = route [ ("search/:term/txt", method GET runHTMLSearch)
              ,("search/:term", method GET runJSONSearch) ]

-- TODO Store this in some snap state i.e. no IO, need to read up on state Monad
getIndexFile :: IO (String)
getIndexFile = do
  args <- getArgs
  let indexFile = head args
  return indexFile

main :: IO ()
main = do
  args <- getArgs
  when (length args < 1) showUsage
  quickHttpServe site

showUsage :: IO ()
showUsage = do
  hPutStrLn stderr "usage: indexFile"
  hPutStrLn stderr "example: geo-server geodata.idx"
  exitFailure


getSearchTerm :: Snap (String)
getSearchTerm = do
  Just term <- getParam "term"
  return $ B.unpack term

runSearch :: Snap([Entry])
runSearch = do
  searchTerm <- getSearchTerm
  indexFile <- ($) liftIO $ getIndexFile
  results <- ($) liftIO $ search indexFile $ searchTerm
  return results

runJSONSearch :: Snap()
runJSONSearch = do
  searchTerm <- getSearchTerm
  results <- runSearch
  modifyResponse $ setContentType "application/json"
  let jsonRes = map (buildJSONEntry) results
  writeLBS $ JSON.encode $ JSON.SearchResult searchTerm (length jsonRes) jsonRes

buildJSONEntry :: Entry -> JSON.JSONEntry
buildJSONEntry entry = do
  let get value = T.unpack . getField $ value
  let convertTags = fromList $ map (\i -> ((get $ key i), (get $ value i))) (getField $ tags entry)

  let jsonEntry = JSON.JSONEntry {
        JSON.term = (T.unpack . getField $ term entry)
      , JSON.latitude = getField $ latitude entry
      , JSON.longitude = getField $ longitude entry
      , JSON.source = (T.unpack . getField $ src entry)
      , JSON.rank = getField $ rank entry
      , JSON.type' = (T.unpack . getField $ type' entry)
      , JSON.tags = convertTags
    }
  jsonEntry

runHTMLSearch :: Snap ()
runHTMLSearch = do
  results <- runSearch
  modifyResponse $ setContentType "text/html"
  writeText "<html><head><title>GeoIndex</title></head><body>"
  mapM_ (printEntry) results
  writeText "</body></html>"

printEntry entry = do
  let latStr = (show . getField $ latitude entry)
  let lonStr = (show . getField $ longitude entry)
  writeBS $ "##################################################<br>"
  writeBS . B.pack $ "# Term:                   " ++ (T.unpack . getField $ term entry) ++ "<br>"
  writeBS . B.pack $ "# Latitude:               " ++ latStr ++ "<br>"
  writeBS . B.pack $ "# Longitude:              " ++ lonStr ++ "<br>"
  writeBS . B.pack $ "# Source:                 " ++ (T.unpack . getField $ src entry) ++ "<br>"
  writeBS . B.pack $ "# Rank:                   " ++ (show . getField $ rank entry) ++ "<br>"
  writeBS . B.pack $ "# Type:                   " ++ (T.unpack . getField $ type' entry) ++ "<br>"
  mapM_ (printTag) $ getField $ tags entry
  writeBS . B.pack $ "# Open Streetmap:         " ++ ("http://www.openstreetmap.org/#map=15/" ++ latStr ++ "/" ++ lonStr) ++ "<br>"
  writeBS . B.pack $ "# Here:                   " ++ ("http://here.com/" ++ latStr ++ "," ++ lonStr ++ ",15,0,0,normal.day") ++ "<br>"
  writeBS . B.pack $ "# Google Maps:            " ++ ("http://www.google.co.uk/maps/@" ++ latStr ++ "," ++ lonStr ++ ",15z") ++ "<br>"
  writeBS . B.pack $ "##################################################<br>"
  where
    printTag tag = do
      writeBS . B.pack $ "# Tag:                    " ++ (T.unpack . getField $ key tag) ++ " = " ++ (T.unpack . getField $ value tag) ++ "<br>"
