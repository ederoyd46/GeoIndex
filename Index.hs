import Text.CSV
import Data.List(map)
import Control.Monad(mapM_)

loadFile :: IO ()
loadFile = do
	csv <- parseCSVFromFile "/var/development/geodata.csv"
	case csv of
		Right d -> decodeFile d
		Left err -> print "File has no data"

--decodeFile :: CSV -> IO ()
decodeFile csv = do
	print $ "File has " ++ (show $ length csv) ++ " entries"
	mapM_ (decodeRow) csv

decodeRow (st:lat:lon:src) = do
	print $ "term" ++ st



decodeRow [] = return ()
decodeRow [x] = return ()
	
	

--loopData [] = []]
--loopData (x:xs) = case  : loopData xs

