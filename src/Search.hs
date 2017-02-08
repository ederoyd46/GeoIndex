{-# LANGUAGE OverloadedStrings #-}

module Search where

import Common
import Data.Binary (decode)
import Data.Binary.Get (Get, getWord64be, getLazyByteString, runGet, bytesRead)
import qualified Data.ByteString.Lazy as ByteString (readFile, drop)
import Data.Int
import qualified Data.Map as M
import Data.ProtocolBuffers (decodeMessage)
import qualified Proto as P
import Data.Serialize (runGetLazy)

search :: String -> String -> IO ([P.Entry])
search f s = do
  handle <- ByteString.readFile f
  let (header, hoffset, soffset) = runGet getHeader handle
  let eoffset = hoffset + soffset
  let rootTerm = parseRootTerm s
  let term = parseTerm' s
  case M.lookup rootTerm header of
    Just (o,s) -> do
      let subIndexData = ByteString.drop (fromIntegral (hoffset + o)) handle
      let subIndex = runGet (getSubIndex s) subIndexData
      case M.lookup term subIndex of
        Just el -> return $ map (
                    \(eo,es) -> do
                      let entryData = ByteString.drop (fromIntegral (eoffset + eo)) handle
                      runGet (getEntry es) entryData :: P.Entry
                   ) el
        Nothing -> return []
    Nothing -> return []

getEntry :: Int64 -> Get P.Entry
getEntry entrySize = do
    entryBytes <- getLazyByteString (fromIntegral entrySize)
    let Right entry = runGetLazy decodeMessage =<< Right entryBytes ::  Either String P.Entry
    return entry

getSubIndex :: Int64 -> Get (M.Map String [(Int64, Int64)])
getSubIndex subIndexSize = do
    subIndexBytes <- getLazyByteString (fromIntegral subIndexSize)
    let subIndex = decode subIndexBytes :: M.Map String [(Int64, Int64)]
    return subIndex

getHeader :: Get (M.Map String (Int64, Int64), Int64, Int64)
getHeader = do
    hlen <- getWord64be
    headerBytes <- getLazyByteString (fromIntegral hlen)
    let header = decode headerBytes :: (M.Map String (Int64, Int64))
    slen <- getWord64be
    offset <- bytesRead
    return (header, offset, fromIntegral slen)
