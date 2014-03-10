{-# LANGUAGE OverloadedStrings #-}

module Index where

import Common
import Text.CSV(parseCSVFromFile, Field, CSV)
import Data.List(map, elemIndex)
import qualified Data.Set as Set (fromList, toList)
import qualified Data.Map as M
import Control.Monad(mapM_, mzero)
import qualified PB.Index.Entry as Entry
import qualified PB.Index.Tag as Tag
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

indexFile :: String -> IO ()
indexFile f = do
  contents <- Char8.readFile f
  let lines = Char8.lines contents
  let entries = map (fromJust) . filter (isJust) $ map (\i -> JSON.decode i :: Maybe JSONEntry) lines
  let indexEntries = map (buildEntry) entries
  {-print $ indexEntries !! 0-}
  {-decodeFile indexEntries-}
  buildTerms indexEntries


buildEntry :: JSONEntry -> Entry.Entry
buildEntry e = do
  let convertTags = map (\i -> Tag.Tag (uFromString (fst i)) (uFromString (snd i))) $ M.toList $ tags e
  Entry.Entry { Entry.term = (uFromString $ term e)
              , Entry.latitude = (uFromString $ show $ latitude e)
              , Entry.longitude = (uFromString $ show $ longitude e) 
              , Entry.src = (uFromString $ source e)
              , Entry.rank = (uFromString $ show $ rank e)
              , Entry.type' = (uFromString $ type' e)
              , Entry.tags = (fromList convertTags)
              }


rootTermLimit :: Int
rootTermLimit = 3

--rootTerm -> term -> entries
buildTerms :: [Entry.Entry] -> IO ()
buildTerms entries = do
  let terms = cleanup $ map (sParseTerm . getSearchTerm) entries :: [String]
  let termEntries = map (\k ->
                          filter (
                            \e -> (sParseTerm (getSearchTerm e)) == k
                          ) entries
                        ) terms
  let termEntryMap = M.fromList $ zip terms termEntries

  let rootTerms = cleanup $ map (take rootTermLimit) terms
  let rootTermEntries = map (\rt -> 
                          M.filterWithKey (\t _ -> 
                            rt == take rootTermLimit t
                          ) termEntryMap 
                        ) rootTerms


  let rootMap = M.fromList $ zip rootTerms rootTermEntries
  print $ length rootTermEntries
  print $ length rootTerms
  print $ M.lookup "LEE" rootMap
  print "done" 
  
  
  
  where
    cleanup = unique . removeBlank
    unique = Set.toList . Set.fromList
    removeBlank = filter (/="") 

--Needs a tidy up!! -- Put on some types so we know what we've got
decodeFile :: [Entry.Entry] -> IO ()
decodeFile entries = do
  putStrLn $ "File has " ++ (show $ length entries) ++ " entries"
  let byteEntries = map (messagePut) entries
  let byteEntrySizes = map (ByteString.length) byteEntries
  let terms = map (sParseTerm . getSearchTerm) entries :: [String]
  let rootTerms = map (take 3) terms




  let byteOffsets = scanl (+) 0 byteEntrySizes :: [Int64]
  let termsMap = (M.fromList $ zip terms (zip byteOffsets byteEntrySizes)) :: M.Map String (Int64, Int64)
  let header = encode termsMap
  let headerSize = ByteString.length header :: Int64
  writeToFile $ encode headerSize
  writeToFile header
  mapM_ (writeToFile) byteEntries
  where
    writeToFile = ByteString.appendFile "/tmp/test.pbf" 


