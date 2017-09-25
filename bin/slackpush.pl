#!/usr/bin/perl

# Simple Slack File Uploader and Downloader Script

use strict;
use Getopt::Std;
use File::Basename;

use Slackpush::File::Upload;
use Slackpush::File::Download;
use Slackpush::Config::Config;

my $VERSION = "0.1";
my ( $softname, $path, $suffix ) = fileparse( $0, qr{\.[^.]*$} );
my $OPTS = "u:d:t:p:n:c:h";
my $USAGE = "$softname.$suffix -f [FILE] -c [CHANNEL] [-h HELP] OPTS[$OPTS]";
my $HELP =<<USAGE;

     Info:

         Softname : $softname.$suffix
         Author   : Dzogovic Vehbo
         Version  : $VERSION

     Options:

     	-u	Upload
	-d	Download (need Fileid)
	-t	Token (set the token to config file)
	-p	Path Of file (default /tmp)
	-n	Filename (default Slack File Name)
	-c	Channel or User (channel should be \\# Because of shell interpreter
	-h	Help

     Usage:

         $USAGE
     
     This Script is using Bash Expression, so you can't declare
     Channel by only using #CHANNEL.
     You need to use the bash backslache for Example:
     $softname.$suffix -u tesfile -c \\#CHANNEL

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

    my (%options) = @_;

    check_file($options{u});

    do_quit(2, "Channel is empty") if ! defined($options{c});

    my $slack = Slackpush::File::Upload->new;

    $slack->setOpt("token", get_token());
    $slack->setOpt("file", $options{u});
    $slack->setOpt("channel", $options{c});

    my $response = $slack->perform;

    if ( $response) {
        do_quit(0,"$softname -> File was uploaded");
    } else {
        do_quit(2,"$softname -> Error while Uploading file");
    };

};

sub curl_download {
    
    my (%options, $token) = @_;
    my $slack = Slackpush::File::Download->new;

    $slack->setOpt("token", get_token());
    $slack->setOpt("fileid", $options{d});
    $slack->setOpt("filename", $options{n}) if defined($options{n});
    $slack->setOpt("filepath", $options{p}) if defined($options{p});

    my $response = $slack->perform;

    if ( $response) {
        do_quit(0, "$softname -> Filename : $response");
    } else {
        do_quit(2,"$softname -> Error while downloading file");
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

my %options=();
getopts($OPTS, \%options);

do_quit(0,$HELP) if defined($options{h});

save_token($options{t}) if defined($options{t});

curl_upload(%options) if defined($options{u});
curl_download(%options) if defined($options{d});

do_quit(0,$HELP);
