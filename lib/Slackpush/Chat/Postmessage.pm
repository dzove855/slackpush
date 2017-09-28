#!/usr/bin/env perl
package Slackpush::Chat::Postmessage;
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
        token 		=> shift,
        text 		=> shift,
        channel 	=> shift,
	as_user		=> "true",
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

    my $slack_url = "https://slack.com/api/chat.postMessage";
    my $curl = WWW::Curl::Easy->new;
    my $curlf = WWW::Curl::Form->new;
    my $json = JSON->new;

    $curl->setopt(CURLOPT_HEADER,0);
    $curl->setopt(CURLOPT_URL, $slack_url);

    foreach my $key (keys %{$self}) {
        $curlf->formadd($key, $self->{$key});
    };

    $curl->setopt(CURLOPT_HTTPPOST, $curlf);

    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

    $curl->perform;

    my $response = $json->decode($response_body);

    return $response->{ok};
};

1;

