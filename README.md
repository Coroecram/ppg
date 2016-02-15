#Pair Programming Git Console
Runner-up at the first appAcademy Hackathon February 2016, Pair Programming Git Console (PPGC)
is a console wrapper that allows, as the name suggests, more efficient pair programming and git
management.

### Usage
As this product is in development, implementation is extraordinarily clunky and forces you to
move all of the files of this repo into your project folder and then `ruby run.rb` from the
command line. For a good demo, you can just do this command inside the cloned folder.

Ideally, PPGC will become a command line gem, a là bundler, and you will just call
`ppg start` from the command line in the directory of your pair programming project.

###Features
PPGC has many functionalities (with more to come) to help pair-programmers:

- Switch timer with running clock on command line
- Countdown timer
- Pause and Unpause the timer
- Reminders to do a commit
- Commit authorship given to navigator
- Push to both repos at the same time
- Entry history with ↑ and ↓ navigation
- More to come

### Development
PPGC is available under the MIT license and I encourage you to get involved with
helping the project.
At the moment, the biggest help would be in writing tests
which then can help everybody stay together on developing moving forward.
Right now, the focus is to reorganize the project so that everything is only created once,
(there is a keypress handler for the intro and then another for the threads)
write a testbase to cover what has been created so far, and then get this project into
a Ruby Gem that can be accessed from the command line.
