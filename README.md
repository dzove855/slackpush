# slackpush

Slackpush is a simple Perl Cli Project to push and Get data from Slack

This Script is inspired from : https://github.com/rlister/slackcat


### Installation

For using this little Script you should be sure to have the following Package installed:
  - Getoprt::Long
  - WWW::Curl
  - WWW::Mechanize
  - Config::INI
  - JSON
  
You should mv the libs in some of the following perl library Path:
perl -e "print qq(@INC)"

Now after all this you should generate a Slack Api token and set it up with:
slackpush.pl -t 'TOKEN'


### Examples

#### Upload File
```
    slackpush.pl --upload="FILE" --channel="#general" 
```

#### Download
```
    slackpush.pl --download="FILEID" --filepath="/tmp" 
```

#### Send Message
```
    slackpush.pl --message="Hello" --channel="#general"
```

Send Message as a bot:
```
    slackpush.pl --message="Hello i'm a bot" --username="slackpush"
```

Send Message from stdin:
```
    echo "heelo" | slackpush.pl --channel="#general"
```
