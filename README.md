# GemUpdater: update your gemfile and retrieve changelogs

Every week or so, you wish to update your `Gemfile`,
to do so, you just have to launch `bundle update`.

Problem is updates *may* break things.
And obviously you need to know what may have broke before pushing your code to production.
Before running your test suite and checking everything is fine,
the first thing you do is probably to look for the changelogs of updated gems.

This process can be quite time consumming:
you need to check on the internet for every updated gems, find where their changelog is hosted,
and probably link to it in your commit message so that other developers will have a chance
to review it too.

`gem_update` will do exactly that for you.
It updates your `Gemfile` (via `bundle update`) and finds links for changelogs of updated gems.
All you have to do is to copy paste the output to the commit message, and you're done!
Obviously, you still have to read changelogs and adapt your code though ;)

## Installation and usage

```
gem install gem_updater
gem_update
<copy paste of output to commit message>
```

## Contributing

PRs are always welcome!
If you wish to contribute, do not hesitate to submit an issue or to open a pull request.
