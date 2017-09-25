# slackpush

Slackpush is a simple Perl Cli Project to push and Get data from Slack

### Installation

For using this little Script you should be sure to have the following Package installed:
  - WWW::Curl
  - WWW::Mechanize
  - Config::INI
  - JSON
  
You should mv the libs in some of the following perl library Path:
perl -e "print qq(@INC)"

Now after all this you should generate a Slack Api token and set it up with:
slackpush.pl -t 'TOKEN'
