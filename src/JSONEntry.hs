{-# LANGUAGE OverloadedStrings #-}

module JSONEntry where

import Control.Monad(mzero)
import Control.Applicative
import qualified Data.Map as M
import Data.Aeson


data SearchResult = SearchResult { searchTerm :: String
                     , count :: Int
                     , results :: [JSONEntry]
                     }


instance FromJSON SearchResult where
    parseJSON (Object v) = SearchResult <$>
                            v .: "searchTerm" <*>
                            v .: "count" <*>
                            v .: "results"
    parseJSON _ = mzero


instance ToJSON SearchResult where
   toJSON (SearchResult searchTerm count results) = object [  "searchTerm" .= searchTerm
                                                            , "count" .= count
                                                            , "results" .= results
                                                           ]

data JSONEntry = JSONEntry {  term :: String
                            , latitude :: Float
                            , longitude :: Float
                            , source :: String
                            , rank :: Float
                            , type' :: String
                            , tags :: M.Map String String
                            } deriving (Show)

instance FromJSON JSONEntry where
     parseJSON (Object v) = JSONEntry <$>
                            v .: "term" <*>
                            v .: "latitude" <*>
                            v .: "longitude" <*>
                            v .: "source" <*>
                            v .: "rank" <*>
                            v .: "type" <*>
                            v .: "tags"
     parseJSON _ = mzero


instance ToJSON JSONEntry where
   toJSON (JSONEntry term latitude longitude source rank type' tags) = object [ "term" .= term
                                                                              , "latitude" .= latitude
                                                                              , "longitude" .= longitude
                                                                              , "source" .= source
                                                                              , "rank" .= rank
                                                                              , "type" .= type'
                                                                              , "tags" .= tags
                                                                              ]
