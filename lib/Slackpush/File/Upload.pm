#!/usr/bin/env perl
package Slackpush::File::Upload;
use strict;
use warnings;
use WWW::Curl::Form;
use WWW::Curl::Easy;
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
        file => shift,
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

    my $slack_url = "https://slack.com/api/files.upload";
    my $curl = WWW::Curl::Easy->new;
    my $curlf = WWW::Curl::Form->new;
    my $json = JSON->new;

    $curl->setopt(CURLOPT_HEADER,0);
    $curl->setopt(CURLOPT_URL, $slack_url);

    $self->{filename} = $self->{file} if ! defined($self->{filename});

    $curlf->formaddfile($self->{file}, 'file', "multipart/form-data");
    $curlf->formadd("token", $self->{token});
    $curlf->formadd("channels", $self->{channel});
    $curlf->formadd("filename", $self->{filename});

    $curl->setopt(CURLOPT_HTTPPOST, $curlf);

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

    $curl->perform;

    my $response = $json->decode($response_body);

    if ($response->{ok} == 1) {
        return 1;
    } else {
        return 0;
    };
};

1;

