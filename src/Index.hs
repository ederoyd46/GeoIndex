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
import Data.Binary (encode, decode)
import Data.Binary.Get (Get, getWord64be)
import Data.Foldable (toList)
import qualified Data.ByteString.Lazy as ByteString (readFile, writeFile, length, appendFile, concat)
import qualified Data.ByteString.Lazy.Char8 as Char8 (readFile, lines, length)
import qualified Data.Aeson as JSON
import JSONEntry
--import Codec.Compression.Zlib as Zlib (compress, decompress)
import Data.Maybe(isJust, fromJust)
import Data.Int

getSearchTerm :: Entry.Entry -> Utf8
getSearchTerm e = getVal e Entry.term

rootTermLimit :: Int
rootTermLimit = 3

indexFile :: String -> IO ()
indexFile f = do
  contents <- Char8.readFile f
  let lines = Char8.lines contents
  let jsonEntries = map (fromJust) . filter (isJust) $ map (\i -> JSON.decode i :: Maybe JSONEntry) lines
  let entries = buildEntries jsonEntries
  let indexData = buildIndex $ fst entries
  writeIndexFile indexData (snd entries)
  where
    writeIndexFile :: (Int64, ByteString, Int64, ByteString) -> ByteString -> IO ()
    writeIndexFile (rootSize,rootIndex,subIndexSize,subIndex) entries = do
      ByteString.writeFile "/tmp/terms.dat" $ ByteString.concat 
            [ encode rootSize
            , rootIndex
            , encode subIndexSize
            , subIndex
            , entries]

buildIndex :: [(String, (Int64, Int64))] -> (Int64, ByteString, Int64, ByteString)
buildIndex indexData = do
  let terms = map (fst) indexData
  let rootTerms = cleanup $ map (take rootTermLimit) terms
  let indexData' = map (\(k,v) -> (k,[v])) indexData --fudge the data into a list so we can build the map..
  let subIndexData = M.toList $ M.fromListWith (++) indexData'
  
  let subIndex = M.toList $ M.fromListWith (++) $ map (
              \v -> do
                let rootTerm = take rootTermLimit (fst v)
                (rootTerm, [v])
              ) subIndexData

  let subIndexTerms = map (fst) subIndex
  let subIndexEntries = map (encode . snd) subIndex
  let sizes = map (ByteString.length) subIndexEntries
  let subIndexSize = foldl1 (+) sizes :: Int64
  let offsets = scanl (+) 0 sizes :: [Int64]
  
  let rootIndex = zip subIndexTerms $ zip offsets sizes
  let rootIndexEntries = encode rootIndex
  let rootIndexSize = ByteString.length rootIndexEntries :: Int64
  (rootIndexSize,rootIndexEntries,subIndexSize,(ByteString.concat subIndexEntries))
  where
    cleanup = unique . removeBlank
    unique = Set.toList . Set.fromList
    removeBlank = filter (/="")


buildEntries :: [JSONEntry] -> ([(String, (Int64, Int64))], ByteString)
buildEntries jsonEntries = do
  let keys = map (parseTerm' . term) jsonEntries
  let entries = map (
        \e -> do
          let b = messagePut . buildEntry $ e
          ((ByteString.length b), b)
        ) jsonEntries
  
  let entryData = map (snd) entries
  let entrySizes = map (fst) entries
  let offsets = scanl (+) 0 entrySizes :: [Int64]
  let indexData = zip keys $ zip offsets entrySizes
  (indexData, (ByteString.concat entryData))
  where
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

