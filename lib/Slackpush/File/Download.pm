#!/usr/bin/env perl
package Slackpush::File::Download;
use strict;
use warnings;
use WWW::Curl::Form;
use WWW::Curl::Easy;
use WWW::Mechanize;
use JSON;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(new);
%EXPORT_TAGS = ( DEFAULT => [qw(&new)]);

sub new{
    my $slackfile = shift;
    my $self = {
        token => shift,
        filename => shift,
	filepath => "/tmp",
        fileid => shift,
        channels => shift
    };

    bless $self, $slackfile;
    return $self;    
};

sub setOpt{
    my ($self, $obj, $value) = @_;
    $self->{$obj} = $value if defined($obj) && defined($value);
    return($self->{$obj});
};

sub perform{
    my ($self) = @_;

    my $slack_url 	= "https://slack.com/api/files.info";
    my $curl 		= WWW::Curl::Easy->new;
    my $curlf 		= WWW::Curl::Form->new;
    my $curlm		= WWW::Mechanize->new;
    my $json 		= JSON->new;

    $curl->setopt(CURLOPT_HEADER,0);
    $curl->setopt(CURLOPT_URL, $slack_url);

    $curlf->formadd("token", $self->{token});
    $curlf->formadd("file", $self->{fileid});

    $curl->setopt(CURLOPT_HTTPPOST, $curlf);

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA,\$response_body);
    $curl->perform;

    my $response 	= $json->decode($response_body);

    if ($response->{ok}) {

        $self->{filepath} =~ s|/$||;
        $self->{filename} = $response->{file}->{name} if ! defined($self->{filename});
        $self->{filename} =~ s| |_|g;  
        $curlm->get($response->{file}->{url_private_download}, "Authorization" => "Bearer $self->{token}", ":content_file" => $self->{filepath} . "/" . $self->{filename});

    } else {

	return 0;

    }

    return $self->{filepath} . '/' . $self->{filename};
};

1;
