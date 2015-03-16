{-# LANGUAGE OverloadedStrings #-}

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

site :: Snap ()
site = route [ ("api/search", method GET runSearch) ]

runSearch :: Snap ()
runSearch = do
  Just term <- getParam "term"
  -- modifyResponse $ setContentType "application/json"
  modifyResponse $ setContentType "text/html"

  -- Just indexFile <- ($) liftIO $ getEnv "indexFile"
  indexFile <- ($) liftIO $ getIndexFile
  results <- ($) liftIO $ search indexFile $ show term
  liftIO . putStrLn $ show results
  writeText "<html><head><title>GeoIndex</title></head><body>"
  mapM_ (printEntry) results
  writeText "</body></html>"


main :: IO ()
main = do
  args <- getArgs
  when (length args < 1) showUsage
  quickHttpServe site

getIndexFile :: IO (String)
getIndexFile = do
  args <- getArgs
  let indexFile = head args
  return indexFile


showUsage :: IO ()
showUsage = do
  hPutStrLn stderr "usage: indexFile"
  hPutStrLn stderr "example: geo-server geodata.idx"
  exitFailure

printEntry entry = do
  writeBS $ "##################################################<br>"
  writeBS . B.pack $ "# Term:                   " ++ (T.unpack . getField $ term entry) ++ "<br>"
  writeBS . B.pack $ "# Latitude:               " ++ (T.unpack . getField $ latitude entry) ++ "<br>"
  writeBS . B.pack $ "# Longitude:              " ++ (T.unpack . getField $ longitude entry) ++ "<br>"
  writeBS . B.pack $ "# Source:                 " ++ (T.unpack . getField $ src entry) ++ "<br>"
  writeBS . B.pack $ "# Rank:                   " ++ (T.unpack . getField $ rank entry) ++ "<br>"
  writeBS . B.pack $ "# Type:                   " ++ (T.unpack . getField $ type' entry) ++ "<br>"
  mapM_ (printTag) $ getField $ tags entry
  writeBS . B.pack $ "# Open Streetmap:         " ++ ("http://www.openstreetmap.org/#map=15/" ++ (T.unpack . getField $ latitude entry) ++ "/" ++ (T.unpack . getField $ longitude entry)) ++ "<br>"
  writeBS . B.pack $ "# Here:                   " ++ ("http://here.com/" ++ (T.unpack . getField $ latitude entry) ++ "," ++ (T.unpack . getField $ longitude entry) ++ ",15,0,0,normal.day") ++ "<br>"
  writeBS . B.pack $ "# Google Maps:            " ++ ("http://www.google.co.uk/maps/@" ++ (T.unpack . getField $ latitude entry) ++ "," ++ (T.unpack . getField $ longitude entry) ++ ",15z") ++ "<br>"
  writeBS . B.pack $ "##################################################<br>"
  where
    printTag tag = do
      writeBS . B.pack $ "# Tag:                    " ++ (T.unpack . getField $ key tag) ++ " = " ++ (T.unpack . getField $ value tag) ++ "<br>"
