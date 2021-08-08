{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

import Additional (footer, header)
import Data.List (sort)
import qualified Data.Text as T
import Database.SQLite.Simple as SQL
  ( Connection,
    FromRow (..),
    Query,
    field,
    open,
    query_,
  )
import System.Directory (copyFile, getTemporaryDirectory)
import System.IO (hClose, hPutStr)
import System.Process.Typed (byteStringOutput, createPipe, getStdin, proc, setStdin, setStdout, withProcessWait_)
import Text.RawString.QQ (r)

data ListItem = ListItem
  { title :: T.Text,
    notes :: T.Text
  }
  deriving (Eq)

mkURL :: T.Text -> T.Text -> T.Text
mkURL title url = T.concat ["[", title, "]", "(", url, ")"]

instance Show ListItem where
  show (ListItem t n) =
    T.unpack . T.concat $
      ["## ", mkURL t url, "\n", notes, "\n\n"]
    where
      (l : ls) = T.lines n
      (url, notes) = case T.lines n of
        (l : ls) | "http" `T.isPrefixOf` l -> (l, T.strip . T.unwords $ ls)
        _ -> ("¿¿¿", n)

instance Ord ListItem where
  compare l r = case ("above" `T.isInfixOf` notes l, "above" `T.isInfixOf` notes r) of
    (True, True) -> LT
    (False, True) -> LT
    (True, False) -> GT
    (False, False) -> EQ

instance FromRow ListItem where
  fromRow = ListItem <$> field <*> field

listQuery :: Query
listQuery =
  [r|
  SELECT t.title, t.notes from TMTask t 
  JOIN TMTask p on p.uuid = t.project 
  WHERE p.title = '📄 Articles' and t.status=3 and t.trashed != 1
|]

selectTasks :: SQL.Connection -> IO [ListItem]
selectTasks conn = SQL.query_ conn listQuery

thingsPath :: FilePath
thingsPath = "/Users/ruben/Library/Group Containers/JLMPQHK86H.com.culturedcode.ThingsMac/Things Database.thingsdatabase/main.sqlite"

tmpPath :: FilePath -> FilePath
tmpPath dir = dir <> "hThings3.sqlite3"

main :: IO ()
main = do
  dir <- getTemporaryDirectory
  let destinationPath = tmpPath dir
  _ <- copyFile thingsPath destinationPath
  conn <- open destinationPath
  tasks <- sort <$> selectTasks conn
  let markdown = T.unpack $ T.strip $ T.pack (concat (header : (map show tasks) ++ [footer]))
  let pbcopyCfg =
        setStdin createPipe $
          setStdout byteStringOutput $
            proc "pbcopy" [""]
  withProcessWait_ pbcopyCfg $ \p -> do
    hPutStr (getStdin p) markdown
    hClose (getStdin p)
  putStrLn ((show $ length tasks) <> " items copied to clipboard ")
  pure ()
