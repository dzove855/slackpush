#!/usr/bin/perl

# Simple Slack File Uploader and Downloader Script

use strict;
use Getopt::Std;
use Getopt::Long;
use File::Basename;
use IO::Handle;

# Custom Libs
use Slackpush::File::Upload;
use Slackpush::File::Download;
use Slackpush::Config::Config;
use Slackpush::Chat::Postmessage;

Getopt::Long::Configure(qw{no_auto_abbrev no_ignore_case_always});

# Should not be setted
# STDIN->blocking(0);

my $VERSION = "0.1";
my $OPTS = "i:I:U:m:u:d:t:p:n:c:sh";
my ( $softname, $path, $suffix ) = fileparse( $0, qr{\.[^.]*$} );
my $USAGE = "$softname$suffix -f [FILE] -c [CHANNEL] [-h HELP] OPTS[$OPTS]";
my $HELP =<<USAGE;

     Info:

         Softname : $softname$suffix
         Author   : Dzogovic Vehbo
         Version  : $VERSION

     Options:

     	-u|--upload	Upload
	-d|--download	Download (need Fileid)
	-t|--token	Token (set the token to config file)
	-p|--filepath	Path Of file (default /tmp)
	-n|--filename	Filename (default Slack File Name)
	-c|--channel	Channel or User (channel should be \\# Because of shell interpreter
	-m|--message	Send Message to user or read stdin
        -s|--stdin      Read Message from stdin
	-U|--username	As_user false and set Username
	-i|--iconemoji	Only with --username
	-I|--iconurl	Only with --username
	-h|--help	Help

     Usage:

         $USAGE
     
     This Script is using Bash Expression, so you can't declare
     Channel by only using #CHANNEL.
     You need to use the bash backslache for Example:
     $softname$suffix -u tesfile -c \\#CHANNEL

     To use this script you need to install libjson-perl,libwww-curl-perl, libwww-mechanize-perl, libconfig-ini-perl 
     and set your token into the token variable.

USAGE

sub do_quit {
    my ($retCode, $msg) = @_;

    print "$msg\n";
    exit $retCode    
};

sub check_file {
    my ($file_to_check) = @_;

    do_quit(2, "file is not set!") if ! defined($file_to_check);
    do_quit(2, "file($file_to_check) does not exist!") if ! -f $file_to_check;
    do_quit(2, "file($file_to_check) is empty") if -z $file_to_check;
};

sub curl_upload {

    my ($options) = @_;

    check_file($options->{upload});

    do_quit(2, "Channel is empty") if ! defined($options->{channel});

    my $slack = Slackpush::File::Upload->new;

    $slack->setOpt("token", get_token());
    $slack->setOpt("file", $options->{upload});
    $slack->setOpt("channel", $options->{channel});

    my $response = $slack->perform;

    if ( $response ) {
        do_quit(0,"$softname -> File was uploaded");
    } else {
        do_quit(2,"$softname -> Error while Uploading file");
    };

};

sub curl_download {
    
    my ($options) = @_;
    my $slack = Slackpush::File::Download->new;

    ($options->{download}) = ($options->{download} =~ m|^https://.+/.+/.+/(.+)/.*|) if $options->{download} =~ m|^https://|;

    $slack->setOpt("token", get_token());
    $slack->setOpt("fileid", $options->{download});
    $slack->setOpt("filename", $options->{filename}) if defined($options->{filename});
    $slack->setOpt("filepath", $options->{filepath}) if defined($options->{filepath});

    my $response = $slack->perform;

    if ( $response ) {
        do_quit(0, "$softname -> Filename : $response");
    } else {
        do_quit(2,"$softname -> Error while downloading file");
    };
};

sub curl_postmessage {
    my ($options, $postmessage, $softname) = @_;

    do_quit(2, "Channel is empty") if ! defined($options->{channel}); 
    my $slack = Slackpush::Chat::Postmessage->new;
    $slack->setOpt("token", get_token());
    $slack->setOpt("channel", $options->{channel});

    $postmessage->{as_user} = "false" if defined($postmessage->{username}) or defined($postmessage->{icon_emoji}) or defined($postmessage->{icon_url});

    $postmessage->{username} = $softname if ! defined($postmessage->{username}) and ! $postmessage->{as_user} == "false";

    foreach my $key (keys %{$postmessage}) {
        $slack->setOpt($key, $postmessage->{$key});
    };

    my $response = $slack->perform;

    if ( $response ) {
        do_quit(0, "$softname -> Message succesfully send to $options->{channel}")
    } else {
        do_quit(2, "$softname -> Error while sendind Message");
    };

};

sub save_token {
    my ($token) = @_;

    my $config = Slackpush::Config::Config->new;

    $config->setOpt("token", $token);
    $config->save("$ENV{'HOME'}/.$softname");

    do_quit(0, "Token succesfully saved") if get_token();
};

sub get_token {
    my $config = Slackpush::Config::Config->new;

    do_quit(2, "Config File Does not exit, check -t options") if ! -f "$ENV{'HOME'}/.$softname";
    do_quit(2, "No Token configured!") if ! defined($config->read($ENV{'HOME'} . '/.' . $softname, 'token'));
    return $config->read($ENV{'HOME'} . '/.' . $softname, 'token');
};

my $options = {};

my $postmessage = {};

GetOptions(
    'help|h' 	 	=> \$options->{help},
    'token|t=s'	 	=> \$options->{token},
    'channel|c=s'	=> \$options->{channel},
    'upload|u=s'	=> \$options->{upload},
    'download|d=s'	=> \$options->{download},
    'filename|n=s'	=> \$options->{filename},
    'filepath|p=s'	=> \$options->{filepath},
    'message|m=s'	=> \$postmessage->{text},
    'stdin|s'           => \$options->{stdin},
    'username|U=s'	=> \$postmessage->{username},
    'iconemoji|i=s'	=> \$postmessage->{icon_emoji},
    'iconurl|I=s'	=> \$postmessage->{icon_url},
);

do_quit(0,$HELP) if defined($options->{help});

save_token($options->{token}) if defined($options->{token});

local $/;
$postmessage->{text} = <STDIN> if ! defined($postmessage->{text}) and defined($options->{stdin});

curl_postmessage($options,$postmessage,$softname) if defined($postmessage->{text});

curl_upload($options) if defined($options->{upload});
curl_download($options) if defined($options->{download});

do_quit(0,$HELP);
