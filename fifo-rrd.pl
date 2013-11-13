#!/usr/bin/perl -w
# fifo-rrd.pl -- part of the GWFL FIFO-RRD Project
# $Id: fifo-rrd.pl,v 1.3 2005/11/21 10:45:03 gary Exp $

use strict;
use POSIX ();
use FindBin ();
use File::Basename ();
use File::Spec::Functions;

use lib qw(/usr/lib/fifo-rrd);
use template_config;
use rrd_templates;
use Validate;
use RRDs;

my $selflog = '/var/log/nagios/fifo-rrd.log';
my $rrdpath = '/home/rrd';
my $pipe = '/var/lib/fifo-rrd/fifo-rrd.pipe';
my $debug = 0; 

my $v = Validate->new('A-Za-z0-9 :\/-|\.');

sub mytime {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	my $t = sprintf "%02d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday,
		$hour, $min, $sec;
	return $t;
}

sub logger {
	return unless @_;
	open(LOG, ">>$selflog") or die "Cannot open $selflog: $!";
	print LOG mytime, " @_\n"; 
	close LOG;
}

sub daemonize {	
	chdir '/' or die "Can't chdir to /: $!";
	open STDIN,  '/dev/null'   or die "Can't read /dev/null: $!";
	open STDOUT, '>>/dev/null' or die "Can't write to /dev/null: $!";
	open STDERR, '>>/dev/null' or die "Can't write to /dev/null: $!";
	defined( my $pid = fork ) or die "Can't fork: $!";
	exit if $pid;
	POSIX::setsid or die "Can't start a new session: $!";
	umask 0;
	logger("Daemon forked");
	$0 = "fifo-rrd: monitoring $pipe";
}

my $script = File::Basename::basename($0);
my $SELF = catfile $FindBin::Bin, $script;

my $sigset = POSIX::SigSet->new();
my $action = POSIX::SigAction->new('huphandler', $sigset, &POSIX::SA_NODEFER);
POSIX::sigaction(&POSIX::SIGHUP, $action);

sub huphandler {
  logger("Received HUP signal, restarting ...");

  if (!exec($SELF, @ARGV)) {
    logger("Could'nt restart: $!");
    die "Could'nt restart: $!";
  }
}

unless (-p $pipe) {
	unlink $pipe;

	if (!POSIX::mkfifo($pipe, 0600)) {
 		logger("Could'nt mknod $pipe: $!");
		die "Could'nt mknod $pipe: $!";
	}

	logger("Created pipe $pipe");
}

unless (-e $rrdpath) {
	if (!mkdir $rrdpath) {
		logger("Could'nt create $rrdpath: $!");
		die "Could'nt create $rrdpath: $!";
	}

	logger("Created $rrdpath");
}

&daemonize;

while (1) {
	if (!open(FIFO, "<$pipe")) {
		logger("Could'nt open pipe: $!");
		die "Could'nt open pipe: $!";
	}

	my $fifo = <FIFO>;
	close FIFO;

	$fifo = $v->filter($fifo); # Better to be safe than sorry.

	logger("FIFO: $fifo") if $debug;

	chomp($fifo);
	my ($host, $service, $output, $perfdata) = split(/\|/, $fifo);
	next unless $perfdata;

	logger("host: $host, service: $service, output: $output, perfdata: $perfdata")
		if $debug;

	my $service2 = $service; 
	
	$service2 =~ s#/# slash #g;
	$service2 =~ s#:##g;
	$service2 = join('_', $host, split(/\s+/, $service2));

	my $graphpath = $rrdpath.'/'.$host.'/'.$service2.'.rrd';
	my $error;

	if (!-e $graphpath) {
		my @rdata = ();

		if (!(@rdata = template_config::build_template($host, $service, 
			\%rrd_templates))) {
			logger("Ignoring pipe data for unconfigured host: $host") if $debug;
			next;
		}

		logger("Creating RRD for $host, service: $service ($graphpath)");	

		mkdir $rrdpath.'/'.$host if (!-e $rrdpath.'/'.$host);
		RRDs::create($graphpath, @rdata);
		
		$error = RRDs::error;
		
		if ($error) {
			logger "Create Error ($host, $service): $error";
			$0 = 'fifo-rrd: create error: '.$error;
		}
	}

	my $update_templ_str = '';
	my $update_value_str = 'N';
	my @perfitems = split(/\s+/, $perfdata);
	
	foreach my $i (@perfitems) {
		$update_value_str .= ':'.$2 if ($i =~ /([^=]+)=(\d+(\.\d*)*)/);
  	$update_templ_str .= ($update_templ_str ne '') ? ':'.$1 : $1; 
	}

	logger("$host ($service) update: --template $update_templ_str $update_value_str")
		if $debug;

	RRDs::update($graphpath, '--template', $update_templ_str, $update_value_str);
	
	$error = RRDs::error;

	if ($error) {
		logger "Update Error ($host, $service): $error";
		$0 = 'fifo-rrd: update error: '.$error;
	}
}

exit 0;
