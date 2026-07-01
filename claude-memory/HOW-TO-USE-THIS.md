# How To Use claude-memory/

At the START of every new session, read 00-PROJECT-STATE.md first, 
then any other file relevant to the task at hand.

At the END of every completed task, BEFORE /clear is run:
1. Update 00-PROJECT-STATE.md — move completed items from 
   "What's NOT Done Yet" to "What's Done"
2. Update 02-BUGS.md — mark any fixed bugs as [FIXED]
3. Append a short entry to 04-SESSION-LOG.md
4. If schema or dependencies changed, update 01-DATABASE-SCHEMA.md 
   or 03-DEPENDENCIES.md

Never let these files go stale. They are the only continuity between 
cleared sessions.
