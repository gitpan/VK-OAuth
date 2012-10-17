package VK::OAuth;


use 5.010;
use strict;
use warnings;

require LWP::UserAgent;
require JSON;
require Carp;

our $VERSION = '0.01';


sub new {
    my $class = shift;
    my $self = bless {@_}, $class;

    Carp::croak("app_id, secret and postback required for this action")
      unless ($self->{app_id} && $self->{secret} && $self->{postback});

    $self->{ua}   ||= LWP::UserAgent->new();
    $self->{json} ||= JSON->new;
    return $self;
}


sub authorize {
    my ($self, $params) = @_;

    my $url = URI->new('https://oauth.vk.com/authorize');
    $url->query_form(
        client_id     => $self->{app_id},
        response_type => 'code',
        redirect_uri  => $self->{postback},
        $params && %$params ? %$params : undef,
    );
    return $url;
}

sub request_access_token {
    my ($self, $code) = @_;

    Carp::croak("code required for this action") unless ($code);
    my $url = URI->new('https://oauth.vk.com/access_token');
    $url->query_form(
        'client_secret' => $self->{secret},
        'client_id'     => $self->{app_id},
        'code'          => $code,
        'redirect_uri'  => $self->{postback},
    );
    my $response = $self->{ua}->get($url);
    return 0 unless $response->is_success;
    my $obj = $self->{json}->decode($response->content);

    # $obj->{user_id}, $obj->{access_token}, $obj->{expires_in}
    return $obj;
}

sub request {
    my ($self, $method, $params, $access_token) = @_;

    Carp::croak("method and access_token required for this action")
      unless ($method && $access_token);
    my $url = URI->new('https://api.vk.com/method/' . $method);
    $url->query_form(
        access_token => $access_token,
        $params && %$params ? %$params : undef,
    );
    my $response = $self->{ua}->get($url);
    return 0 unless $response->is_success;
    my $obj = $self->{json}->decode($response->content);

    return $obj;
}

1;


__END__

=pod

=head1 NAME

VK::OAuth - OAuth authorization on your site with VK API

=head1 SYNOPSIS

  my $object = VK::OAuth->new(
      app_id     => 'YOUR APP ID',
      secret     => 'YOUR APP SECRET',
      postback   => 'POSTBACK URL',
  );
  


=head1 DESCRIPTION

Use this module for input VK OAuth authorization on your site

=head1 METHODS

=head2 new

  my $vk = VK::OAuth->new(
      app_id     => 'YOUR APP ID',
      secret     => 'YOUR APP SECRET',
      postback   => 'POSTBACK URL',
  );

The C<new> constructor lets you create a new B<VK::OAuth> object.

=head2 authorize

	my $url = $vk->authorize( {option => 'value'} );
	# Your web app redirect method.
	$self->redirect($url);

This method returns a URL, for which you want to redirect the user.

=head3 Options

http://vk.com/developers.php?oid=-1&p=Авторизация_сайтов

=head3 Response

Method returns URI object.

=head2 request_access_token

This method gets access token from VK API.

=head3 Options

code - returned in redirected get request from authorize API method.

=head3 Response

Method returns HASH object with keys $obj->{user_id}, $obj->{access_token}, $obj->{expires_in}.

=head2 request

This method sends requests to VK API.

=head3 Options

method (required)       - returned in redirected get request from authorize API method;
params (not required)   - other params;
access_token (required) - access token.

=head3 Response

Method returns HASH object with requested data.


=head1 SUPPORT

Github: https://github.com/Foxcool/VK-OAuth

More information:
	Authorization - http://vk.com/developers.php?oid=-1&p=Авторизация_сайтов
	API methods   - http://vk.com/developers.php?oid=-1&p=Описание_методов_API
	And others in http://vk.com/developers.php

=head1 AUTHOR

Copyright 2012 Alexander Babenko.

=cut
