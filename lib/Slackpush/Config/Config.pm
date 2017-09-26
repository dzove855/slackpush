#!/usr/bin/env perl

package Slackpush::Config::Config;
use strict;
use warnings;
use Config::INI::Writer;
use Config::INI::Reader;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(new);
%EXPORT_TAGS = ( DEFAULT => [qw(&new)]);

sub new{
    my $config = shift;
    my $self = {
    };

    bless $self, $config;
    return $self;    
};

sub setOpt{
    my ($self, $obj, $value) = @_;
    $self->{$obj} = $value if defined($obj) && defined($value);
    return($self->{$obj});
};

sub save{
    my ($self, $configfile) = @_;

    return 0 if ! defined($configfile);

    foreach my $key (keys %{$self}) {
       Config::INI::Writer->write_file({'_' => { $key => $self->{$key}}}, $configfile);
    }
    chmod 0600, $configfile;

    return 1;
};

sub read{
    my ($self, $configfile, $value) = @_;
    return "Error" if ! defined($configfile) or ! defined($value);
    my $config_hash = Config::INI::Reader->read_file($configfile);
    return $config_hash->{_}->{$value} if defined($config_hash->{_}->{$value});

};

1;

