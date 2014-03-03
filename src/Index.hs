{-# LANGUAGE OverloadedStrings #-}

module Index where

import Common
import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map, elemIndex)
import qualified Data.Map as M
import Control.Monad(mapM_, mzero)
import qualified PB.Index.Entry as Entry
import Text.ProtocolBuffers.Basic (ByteString, uFromString, uToString, Int64, Seq, Utf8)
import Text.ProtocolBuffers (getVal)
import Data.Sequence(fromList)
import Text.ProtocolBuffers.WireMessage (messagePut)
import Data.Binary (encode)
import Data.Binary.Get (Get, getWord64be)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile)
import qualified Data.ByteString.Lazy.Char8 as Char8 (readFile, lines, length)
import qualified Data.Aeson as JSON
import Control.Applicative

--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Maybe(isJust, fromJust)
import Data.Int

getSearchTerm :: Entry.Entry -> Utf8
getSearchTerm e = getVal e Entry.term

printEntry (st:lat:lon:src:rank:type':tags) = tags

buildEntry :: [Field] -> Maybe Entry.Entry
buildEntry (st:lat:lon:src:rank:type':tags) = Just $ Entry.Entry { Entry.term = (uFromString st)
                                                              , Entry.latitude = (uFromString lat)
                                                              , Entry.longitude = (uFromString lon) 
                                                              , Entry.src = (uFromString src)
                                                              , Entry.rank = (uFromString rank)
                                                              , Entry.type' = (uFromString type')
                                                              , Entry.tags = (fromList []) }
buildEntry [x] = Nothing
buildEntry [] = Nothing

data JSONEntry = JSONEntry {  term :: String
                            , latitude :: Float
                            , longitude :: Float
                            , source :: String
                            , rank :: Float
                            , type' :: String
                            , tags :: (M.Map String String)
                            } deriving (Show)

instance JSON.FromJSON JSONEntry where
     parseJSON (JSON.Object v) = JSONEntry <$>
                            v JSON..: "searchTerm" <*>
                            v JSON..: "latitude" <*>
                            v JSON..: "longitude" <*>
                            v JSON..: "source" <*>
                            v JSON..: "rank" <*>
                            v JSON..: "type" <*>
                            v JSON..: "tags"
     parseJSON _ = mzero


indexFile3 f = do
  contents <- Char8.readFile f
  let lines = Char8.lines contents
  let entries = map (fromJust) . filter (isJust) $ map (\i -> JSON.decode i :: Maybe JSONEntry) lines
  {-let indexEntries = map (buildEntry3) entries-}
  print $ entries !! 0


buildEntry3 :: JSONEntry -> Entry.Entry
buildEntry3 e = Entry.Entry { Entry.term = (uFromString $ term e)
                            , Entry.latitude = (uFromString $ show $ latitude e)
                            , Entry.longitude = (uFromString $ show $ longitude e) 
                            , Entry.src = (uFromString $ source e)
                            , Entry.rank = (uFromString $ show $ rank e)
                            , Entry.type' = (uFromString $ type' e)
                            , Entry.tags = (fromList []) }


indexFile :: String -> IO ()
indexFile f = do
  csv <- parseCSVFromFile f
  case csv of
    Right d -> decodeFile d
    Left err -> putStrLn "File has no data"

--Needs a tidy up!! -- Put on some types so we know what we've got
decodeFile :: CSV -> IO ()
decodeFile csv = do
  putStrLn $ "File has " ++ (show $ length csv) ++ " entries"
  let entries = filter (isJust) $ map (buildEntry) csv
  let byteEntries = map (messagePut . fromJust) entries
  let byteEntrySizes = map (ByteString.length) byteEntries
  let terms = map (sParseTerm . getSearchTerm . fromJust) entries :: [String]
  let byteOffsets = scanl (+) 0 byteEntrySizes :: [Int64]
  let termsMap = (M.fromList $ zip terms (zip byteOffsets byteEntrySizes)) :: M.Map String (Int64, Int64)
  let header = encode termsMap
  let headerSize = ByteString.length header :: Int64
  
  writeToFile $ encode headerSize
  writeToFile header
  mapM_ (writeToFile) byteEntries

  where
    writeToFile = ByteString.appendFile "/tmp/test.pbf" 

