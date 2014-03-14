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
  print $ "Parsed to lines"
  let jsonEntries = map (fromJust) . filter (isJust) $ map (\i -> JSON.decode i :: Maybe JSONEntry) lines
  print $ "Building Entries"
  let entryData = buildEntries jsonEntries
  print $ "Building Index"
  let indexData = buildIndex $ fst entryData
  print $ "Writing Index"
  writeIndexFile indexData (snd entryData)
  print $ "Done"
  where
    writeIndexFile :: (Int64, ByteString, [ByteString]) -> [ByteString] -> IO ()
    writeIndexFile (rootSize,rootIndex,subIndex) entries = do
      print $ "Writing Root Size: " ++ (show rootSize)
      writeToFile $ encode rootSize
      print $ "Writing Root Index"
      writeToFile rootIndex
      print $ "Writing Sub Index"
      mapM_ (writeToFile) subIndex
      print $ "Writing Entries Index"
      mapM_ (writeToFile) entries
      where
        writeToFile = ByteString.appendFile "/tmp/test.pbf"


buildIndex :: [(String, (Int64, Int64))] -> (Int64, ByteString, [ByteString])
buildIndex indexData = do
  let terms = map (\(term,_) -> term) indexData
  let rootTerms = cleanup $ map (\(term,_) -> take rootTermLimit term) indexData
  let indexDataMap = M.fromList $ map (
        \t -> do
          let matches = map (snd) $ filter (
                \(term,_) -> 
                  t == term
                ) indexData
          (t,matches)
        ) terms
  
  let subIndex = map (
        \rt -> do
          let matches = M.filterWithKey (
                \k v -> 
                  (take rootTermLimit k) == rt
                ) indexDataMap
          (rt, encode matches)
        ) rootTerms
  
  let subIndexTerms = map (fst) subIndex
  let subIndexEntries = map (snd) subIndex
  let sizes = map (ByteString.length) subIndexEntries
  let offsets = scanl (+) 0 sizes :: [Int64]

  let rootIndex = M.fromList $ zip subIndexTerms $ zip offsets sizes
  let rootIndexEntries = encode rootIndex
  let rootIndexSize = ByteString.length rootIndexEntries :: Int64
  (rootIndexSize,rootIndexEntries,subIndexEntries) 
  where
    cleanup = unique . removeBlank
    unique = Set.toList . Set.fromList
    removeBlank = filter (/="")


buildEntries :: [JSONEntry] -> ([(String, (Int64, Int64))], [ByteString])
buildEntries jsonEntries = do
  let keys = map (parseTerm' . term) jsonEntries
  let entries = map (messagePut . buildEntry) jsonEntries
  let entrySizes = map (ByteString.length) entries
  let offsets = scanl (+) 0 entrySizes :: [Int64]
  let indexData = zip keys $ zip offsets entrySizes
  (indexData, entries)
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


