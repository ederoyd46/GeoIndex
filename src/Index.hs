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

rootTermLimit :: Int
rootTermLimit = 3

indexFile :: String -> IO ()
indexFile f = do
  contents <- Char8.readFile f
  let lines = Char8.lines contents
  let entries = map (fromJust) . filter (isJust) $ map (\i -> JSON.decode i :: Maybe JSONEntry) lines
  let indexKeys = map (parseTerm' . term) entries
  let indexEntries = map (buildEntry) entries

  --Binary Data
  let binEntries = map (messagePut) indexEntries -- Should be merged with previous line
  let binEntrySizes = map (ByteString.length) binEntries
  let binOffsets = scanl (+) 0 binEntrySizes :: [Int64]
  
  --Index Header Data
  let indexHeaderData = zip3 indexKeys binOffsets binEntrySizes

  {-let dataTree = buildDataTree indexEntries-}
  print $ filter (\(e,f,g) -> e == "LEEDS") indexHeaderData

  {-writeIndexFile dataTree-}


{-writeEntries :: [Entry.Entry] -> Map (-}
{-writeEntries indexEntries = do-}
  


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


buildDataTree :: [Entry.Entry] -> M.Map String (M.Map String [Entry.Entry])
buildDataTree entries = do
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
  M.fromList $ zip rootTerms rootTermEntries
  where
    cleanup = unique . removeBlank
    unique = Set.toList . Set.fromList
    removeBlank = filter (/="") 


writeIndexFile :: M.Map String (M.Map String [Entry.Entry]) -> IO ()
writeIndexFile dataTree = do
  putStrLn $ "File has " ++ (show . length $ M.keys dataTree) ++ " root entries"
  -- ROOT
  --    | TERM
  --          | ENTRY MAP
  -- rt = root term
 
  let rootBlar = M.map

  let rootOffset = map (\rt -> do
                      let rte = M.lookup rt dataTree
                      {-M.map (\tk tvm -> do-}
                        
                      {-) rte-}
                      rte
                   ) (M.keys dataTree)
  print $ rootOffset
  {-let byteEntries = map (messagePut) entries-}
  {-let byteEntrySizes = map (ByteString.length) byteEntries-}
  {-let terms = map (sParseTerm . getSearchTerm) entries :: [String]-}
  {-let rootTerms = map (take 3) terms-}

  {-let byteOffsets = scanl (+) 0 byteEntrySizes :: [Int64]-}
  {-let termsMap = (M.fromList $ zip terms (zip byteOffsets byteEntrySizes)) :: M.Map String (Int64, Int64)-}
  {-let header = encode termsMap-}
  {-let headerSize = ByteString.length header :: Int64-}
  {-writeToFile $ encode headerSize-}
  {-writeToFile header-}
  {-mapM_ (writeToFile) byteEntries-}
  {-where-}
    {-writeToFile = ByteString.appendFile "/tmp/test.pbf" -}



--Needs a tidy up!! -- Put on some types so we know what we've got
{-decodeFile :: [Entry.Entry] -> IO ()-}
{-decodeFile entries = do-}
  {-putStrLn $ "File has " ++ (show $ length entries) ++ " entries"-}
  {-let byteEntries = map (messagePut) entries-}
  {-let byteEntrySizes = map (ByteString.length) byteEntries-}
  {-let terms = map (sParseTerm . getSearchTerm) entries :: [String]-}
  {-let rootTerms = map (take 3) terms-}

  {-let byteOffsets = scanl (+) 0 byteEntrySizes :: [Int64]-}
  {-let termsMap = (M.fromList $ zip terms (zip byteOffsets byteEntrySizes)) :: M.Map String (Int64, Int64)-}
  {-let header = encode termsMap-}
  {-let headerSize = ByteString.length header :: Int64-}
  {-writeToFile $ encode headerSize-}
  {-writeToFile header-}
  {-mapM_ (writeToFile) byteEntries-}
  {-where-}
    {-writeToFile = ByteString.appendFile "/tmp/test.pbf" -}


