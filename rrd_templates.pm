# rrd_templates.pm -- part of the GWFL FIFO-RRD Project
# $Id: rrd_templates.pm,v 1.3 2005/11/18 06:52:13 gary Exp $

package rrd_templates;

use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(%rrd_templates);
our @EXPORT_OK = qw(%rrd_templates);

# interface rrd templates used in the main rrd_templates config hash below
my %iface_rrd_templates = (
	'Interface Traffic' => [
      'DS:ifinoctets:COUNTER:600:U:U',
      'DS:ifoutoctets:COUNTER:600:U:U',
  ],
  'Interface Errors/Discards' => [
    'DS:ifinerrors:COUNTER:600:U:U',
    'DS:ifouterrors:COUNTER:600:U:U',
    'DS:ifindiscards:COUNTER:600:U:U',
    'DS:ifoutdiscards:COUNTER:600:U:U',
  ],
);

# disk io rrd templates used in the main rrd_templates config hash below
my %diskio_rrd_templates = (
	'Bytes read/written' => [
		'DS:bread:COUNTER:600:U:U',
    'DS:bwritten:COUNTER:600:U:U',
  ],
);

our %rrd_templates = (

	# Template common to all graphs (no lossy adjustment). You can either
	# use this global one or section specific Templates. One motivation
	# for section specific a Template would be to use a different step
	# for that set of RRDs. To do so, just place an array reference like
	# the one below inside one of the below subhashes, with the desired
	# changes made.
	'Template' => [
		'-s 60',
		'RRA:AVERAGE:0.5:1:105120', # 365 days worth of 5 min entries
		'RRA:MAX:0.5:1:105120', # Unnecessary with example RRD-Graph config
		'RRA:LAST:0.5:1:105120', # Unnecessary with example RRD-Graph config
	],
	
	# Linux specific templates
	'Linux' => {
		'Total Processes' => [
			'DS:numprocesses:GAUGE:600:U:U',
		],
		'DL360G4 Temperatures' => [
			'DS:IOzone:GAUGE:600:U:U',
			'DS:CPU1:GAUGE:600:U:U',
			'DS:CPU2:GAUGE:600:U:U',
			'DS:PSUbay:GAUGE:600:U:U',
			'DS:SYSboard:GAUGE:600:U:U',
		],
		'DL360G3 Temperatures' => [
			'DS:CPUzone:GAUGE:600:U:U',
			'DS:CPU1:GAUGE:600:U:U',
			'DS:IOzone:GAUGE:600:U:U',
			'DS:CPU2:GAUGE:600:U:U',
		],
		'DL380G4 Temperatures' => [
			'DS:CPUzone:GAUGE:600:U:U',
			'DS:CPU1:GAUGE:600:U:U',
			'DS:IOzone:GAUGE:600:U:U',
			'DS:CPU2:GAUGE:600:U:U',
			'DS:PSUbay:GAUGE:600:U:U',
		],
		'Load Average' => [
			'DS:1min:GAUGE:600:U:U',
			'DS:5min:GAUGE:600:U:U',
			'DS:15min:GAUGE:600:U:U',
		],
		'Swap Utilisation' => [
			'DS:usedpercent:GAUGE:600:U:U',
		],
		'CPU Utilisation' => [
			'DS:utilpercent:GAUGE:600:U:U',
		],
		'RAM Utilisation' => [
	  	'DS:usedpercent:GAUGE:600:U:U',
	  ],
	  'FS: /' => [
	    'DS:usedpercent:GAUGE:600:U:U',
	    'DS:reserved:GAUGE:600:U:U',
	  ],
	  'FS: /var' => [
	    'DS:usedpercent:GAUGE:600:U:U',
	    'DS:reserved:GAUGE:600:U:U',
	  ],
	  'Disk IO - /dev/cciss/c0d0' => [ @{$diskio_rrd_templates{'Bytes read/written'}} ],
	},

	# Netscreen templates
	'Netscreen' => {
	  'CPU Utilisation' => [
			'DS:1min:GAUGE:600:U:U',
			'DS:5min:GAUGE:600:U:U',
			'DS:15min:GAUGE:600:U:U',
		],
		'RAM Utilisation' => [
			'DS:usedpercent:GAUGE:600:U:U',
		],
		'Session Utilisation' => [
			'DS:used:GAUGE:600:U:U',
			'DS:failed:GAUGE:600:U:U',
		],
	},

	# Cisco Switch templates
	'Cisco Switch' => { 
		'CPU Utilisation' => [
	    'DS:1min:GAUGE:600:U:U',
	    'DS:5min:GAUGE:600:U:U',
		],
		'Memory Utilisation' => [
	    'DS:usedpercent:GAUGE:600:U:U',
	  ],
		'Interface 1/1 Traffic' => [ @{$iface_rrd_templates{'Interface Traffic'}} ],
		'Interface 1/1 Errors/Discards' => [ @{$iface_rrd_templates{'Interface Errors/Discards'}} ],
	},

	# Cisco CSS
	'Cisco CSS' => {
		'CPU Utilisation' => [
      'DS:current:GAUGE:600:U:U',
      'DS:average:GAUGE:600:U:U',
    ],
	},
	
	# ICMP templates
	'ICMP' => {
		'PING Latency' => [
			'DS:packetloss:GAUGE:600:U:U',
			'DS:rta:GAUGE:600:U:U',
		],
	},
);              

1;
