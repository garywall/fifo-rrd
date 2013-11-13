# template_config.pm -- part of the GWFL FIFO-RRD Project
# $Id: template_config.pm,v 1.2 2005/11/18 06:53:01 gary Exp $

package template_config;

use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(template_groups build_template);
our @EXPORT_OK = qw(template_groups build_template);

my %template_config = (
	# Linux boxes
	'LinuxBox1' => { 'default' => 'Linux', 'others' => [ 'ICMP' ] },
	
	# Netscreen Firewalls	 
	'Netscreen1' => { 'default' => 'Netscreen', 'others' => [ 'ICMP' ] },

	# Cisco Switches
	'CiscoSW1' => { 'default' => 'Cisco Switch', 'others' => [ 'ICMP' ] },

	# Cisco CSS
	'CiscoCSS1' => { 'default' => 'Cisco CSS', 'others' => [ 'ICMP' ] },

	# Networks
	'Network1' => { 'default' => 'ICMP' },
);

sub template_groups {
	my $host = shift;
	my @groups = ();

	return () unless (defined($template_config{$host}) &&
		defined($template_config{$host}{'default'}));

	push(@groups, $template_config{$host}{'default'});

	@groups = defined($template_config{$host}{'others'}) ?
		(@groups, @{$template_config{$host}{'others'}}) : @groups;

	return @groups;
}

sub build_template {
  my ($host, $service, $obj) = @_;
  my $found = 0;
	my @groups = ();
	my @gdata = ();
	my @tdata = ();
	
	return () if (!(@groups = template_groups($host)));

	foreach my $group (@groups) {
  
		foreach my $key (keys %{$obj->{$group}}) {
  	  next unless ($service eq $key);
  	  $found++;

  	  print "duplicate templates for '$service' while loading".
				"for $host"  if ($found > 1);

			# Add any section template data
			@tdata = @{$obj->{$group}{'Template'}} if
				defined($obj->{$group}{'Template'}); 
    
			@gdata = @{$obj->{$group}{$key}};
  	}
	}

	@tdata = @tdata ? (@{$obj->{'Template'}}, @tdata) : 
		@{$obj->{'Template'}} if (defined($obj->{'Template'}) && $found);

  return (@tdata, @gdata);
}

1;
