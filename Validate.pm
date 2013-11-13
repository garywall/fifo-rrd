# Perl Input Validation Module -- part of the GWFL RRD-Graph Project
# $Id: Validate.pm,v 1.1 2005/11/18 06:34:12 gary Exp $

package Validate;

use strict;

sub new {
	my $class = shift;
	my $self = {
		'positive' => shift || undef
	};
	
	bless($self, $class);
	return $self;
}

sub filter {
	my $self = shift;
	my $positive = $self->{'positive'} || 'A-Za-z0-9\ ._';
	$_ = "@_";

	# First, remove all standard negative characters.
	s/[\<\>\"\'\%\;\)\(\&\+]//g;
	
	# Second, filter all but the positive characters.
	eval "tr/$positive//dc";
	die $@ if $@;

	return $_;
}

sub positive {
	my $self = shift;

	$self->{'positive'} = shift if @_;
	return $self->{'positive'};
}

=head1 NAME

Perl Input Sanitization Module

=head1 DESCRIPTION

	The focus of this module is to help web developers 
	filter malicious data being passed to CGI scripts. It 
	works by imposing a negative character filter on the 
	data, and then a positive character limit on the data 
	for safety. The web developer can either choose to 
	accept the default positive match, or provide one 
	themselves.

	Usage:

	use lib qw(/path/to/directory/of/Sanitize.pm);
	use Sanitize;

	my $v = Sanitize->new;	# Initialize the object
	$v->positive('A-Za-z0-9\ ._');	# Set the positive match

	Alternatively, the positive match may be set when 
	initializing the object:

	my $v = Sanitize->new('A-Za-z0-9\ ._');

	Filtering of the data is done as follows:

	$filtered_data = $v->filter($cgi_variable);
	
=head1 AUTHORS

Gary Wall <gary@daimonic.org>, with data taken from
http://www.cert.org/tech_tips/malicious_code_mitigation.html

=cut

1;
