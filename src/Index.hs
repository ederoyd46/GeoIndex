{-# LANGUAGE OverloadedStrings #-}

module Index where

import Prelude hiding (length, writeFile, concat)
import Common
import qualified Data.Set as Set (fromList, toList)
import qualified Data.Map as M
import Data.Binary (encode)
import qualified Proto as P
import Data.ByteString.Lazy(ByteString, writeFile, length, concat)
import qualified Data.ByteString.Lazy.Char8 as Char8 (readFile, lines)
import qualified Data.Aeson as JSON
import JSONEntry
import Data.Maybe(mapMaybe)
import Data.Int
import Data.ProtocolBuffers (putField, encodeMessage)
import qualified Data.Text as T
import Data.Serialize (runPutLazy)

rootTermLimit :: Int
rootTermLimit = 3

indexFile :: String -> String -> IO ()
indexFile f i = do
  contents <- Char8.readFile f
  let lines = Char8.lines contents
  let jsonEntries = mapMaybe (\i -> JSON.decode i :: Maybe JSONEntry) lines
  let entries = buildEntries jsonEntries
  let indexData = buildIndex $ fst entries
  writeIndexFile indexData (snd entries)
  where
    writeIndexFile :: (Int64, ByteString, Int64, ByteString) -> ByteString -> IO ()
    writeIndexFile (rootSize,rootIndex,subIndexSize,subIndex) entries =
      writeFile i $ concat
            [ encode rootSize
            , rootIndex
            , encode subIndexSize
            , subIndex
            , entries]

buildIndex :: [(String, (Int64, Int64))] -> (Int64, ByteString, Int64, ByteString)
buildIndex indexData = do
  let terms = map fst indexData
  let rootTerms = cleanup $ map (take rootTermLimit) terms
  let indexData' = map (\(k,v) -> (take rootTermLimit k,[(k, [v])])) indexData
  --This gives us :: rootkey -> [(key, [(offset, size)])]
  let subIndex = M.fromListWith (++) indexData'
  let subIndex' = M.map (M.fromListWith (++)) subIndex

  let subIndexTerms = M.keys subIndex'
  let subIndexEntries = map encode $ M.elems subIndex'

  let sizes = map length subIndexEntries
  let subIndexSize = sum sizes :: Int64
  let offsets = scanl (+) 0 sizes :: [Int64]

  let rootIndex = zip subIndexTerms $ zip offsets sizes
  let rootIndexEntries = encode rootIndex
  let rootIndexSize = length rootIndexEntries :: Int64
  (rootIndexSize,rootIndexEntries,subIndexSize,concat subIndexEntries)
  where
    cleanup = unique . removeBlank
    unique = Set.toList . Set.fromList
    removeBlank = filter (/="")


buildEntries :: [JSONEntry] -> ([(String, (Int64, Int64))], ByteString)
buildEntries jsonEntries = do
  let keys = map (parseTerm' . term) jsonEntries
  let entries = map (
        \e -> do
          let b = runPutLazy $ encodeMessage $ buildEntry $ e
          (length b, b)
        ) jsonEntries

  let entryData = map snd entries
  let entrySizes = map fst entries
  let offsets = scanl (+) 0 entrySizes :: [Int64]
  let indexData = zip keys $ zip offsets entrySizes
  (indexData, concat entryData)
  where
    buildEntry :: JSONEntry -> P.Entry
    buildEntry e = do
      let putStrField s = putField (T.pack s)
      let convertTags = map (\i -> P.Tag (putStrField (fst i)) (putStrField (snd i))) $ M.toList $ tags e
      P.Entry { P.term = putStrField $ term e
                  , P.latitude = putField $ latitude e
                  , P.longitude = putField $ longitude e
                  , P.src = putStrField $ source e
                  , P.rank = putField $ rank e
                  , P.type' = putStrField $ type' e
                  , P.tags = putField convertTags
                  }
