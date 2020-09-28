# hweekly

I semi-regularly collect my reading into blog posts (see [here](https://mostlymaths.net/tags/readingsoftheweek/)). The tracking of what I read is via [Things](https://culturedcode.com/things/), where I store _article/book/talk title_ (as task title) and URL in the notes section (for articles and talks usually). For books, I usually add the book title _only_ and look for the book URL later. The process to create these posts has evolved:

- Delete uninteresting, manually copy the interesting title+link into a Markdown document, add any commentary
- AppleScript that fetches _done_ tasks in the `Articles` project and auto-formats title+link. Add any commentary
- Add the commentary just after reading the article (or before running the above script), modify script to add the notes as well
- Delete uninteresting articles instead of marking as done to reduce overhead, run the script

This has reduced the time needed tremendously, but there was a problematic step left: since I usually didn't have URLs for books, the AppleScript script would silently fail for book records. Also, adding functionality to Applescripts makes for a not-fun experience. 

So late this weekend I wrote this small Haskell utility to remove AppleScript from my life. It has the added bonus of 

- Not failing for tasks without URL (it marks them with `¿` which is a glyph I never use so I can search for it)
- Adding the Hugo header and the footer I use
- Being easily extensible (I could add a "search in amazon" for books directly)

**Note 1**: that this could be a [stack script](https://www.fpcomplete.com/haskell/tutorial/stack-script/), but I find having a binary I can easily `stack install` to be very convenient.

**Note 2**: yes, I'm prefixing all my Haskell repos with `h`.

**Note 3**: I tried using [Selda](https://selda.link) for the SQL, but couldn't figure out how to go from `Result` to a record. [sqlite-simple](https://hackage.haskell.org/package/sqlite-simple) is easy enough especially for such a simple use case. I shouldn't have bothered!

**Note 4**: There are no tests on purpose, this is small enoguh that I can just run and confirm it works as expected or will fail with enough information to fix.
