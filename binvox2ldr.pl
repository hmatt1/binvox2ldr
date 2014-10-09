#!/usr/bin/perl

use strict;
use warnings;

my ($filename) = @ARGV;

if ( ! $filename ) {
	print "Usage: perl $0 \$filename\n";
	exit(2);
}

open(my $fh, "<", $filename) or die "Failed to open file: $filename\n$!";

my $rotate_data = "1 0 0 0 1 0 0 0 1";
my $side_length = 10000000;


while (<$fh>){
	if ( /^dim/ ) {
		$side_length = (split('\s+', $_))[1];
	}
	if ( /^data/ ) {
		last;
	}
}

my @blocks = ( { "x"    => 2,
				 "y"    => 10,
				 "num"  => "3006.DAT",
				},
				{ "x"    => 2,
				 "y"    => 8,
				 "num"  => "3007.DAT",
				},
				{ "x"    => 2,
				 "y"    => 6,
				 "num"  => "2456.DAT",
				},
				{ "x"    => 2,
				 "y"    => 4,
				 "num"  => "3001.DAT",
				},
				{ "x"    => 2,
				 "y"    => 3,
				 "num"  => "3002.DAT",
				},
				{ "x"    => 2,
				 "y"    => 2,
				 "num"  => "3003.DAT",
				},
				{ "x"    => 1,
				 "y"    => 8,
				 "num"  => "3008.DAT",
				},
				{ "x"    => 1,
				 "y"    => 6,
				 "num"  => "3009.DAT",
				},
				{ "x"    => 1,
				 "y"    => 4,
				 "num"  => "3010.DAT",
				},
				{ "x"    => 1,
				 "y"    => 3,
				 "num"  => "3622.DAT",
				},
				{ "x"    => 1,
				 "y"    => 2,
				 "num"  => "3004.DAT",
				},
				{ "x"    => 1,
				 "y"    => 1,
				 "num"  => "3005.DAT",
				}
			);
my ($x, $y, $z) = (0, 0, 0);
while(1) {
	my @rows;
	for ( my $index = 0; $index < $side_length; $index++ ) {
		my $line = <$fh>;
		if ( ! $line ) {
			exit(0);
		}
		my @voxels = split('\s+', $line);
		push @rows, \@voxels;
	}
	
	
	for my $block_ref (@blocks) {
		for my $r (0..$#rows) {
			my @voxels = @{$rows[$r]};
			for my $index (0..$#voxels) {
				$y = $index;
				if ( $voxels[$index] == 1 ) {
					
					my $block_end = $index + $block_ref->{'x'} ;
					my $row_end = $r + $block_ref->{'y'};
					
					if ( $block_end <= $#voxels and $row_end <= $#rows ) {
					
						my $matching_blocks = 0;
						my $expected_match = $block_ref->{'x'} * $block_ref->{'y'};
						for ( my $block_index = $index; $block_index < $block_end; $block_index++ ) {
							for ( my $row_index = $r; $row_index < $row_end; $row_index++ ) {
								if ( $rows[$row_index][$block_index] == 1 ) {
									$matching_blocks++;
								}
							}
						}
						if ( $matching_blocks == $expected_match ) {
							my $x_ = $x + ($block_ref->{'y'} - 1) / 2;
							my $y_ = $y + ($block_ref->{'x'} - 1) / 2;
							my $z_ = $z;
							print "1 0 " . $x_ * 20 . " " . $z_ * 24 . " " . $y_ * 20 . " " . $rotate_data . " " . $block_ref->{'num'} . "\n";
							for ( my $block_index = $index; $block_index < $block_end; $block_index++ ) {
								for ( my $row_index = $r; $row_index < $row_end; $row_index++ ) {
									$rows[$row_index][$block_index] = 2;
								}
							}
						}
					}
				}
			}
			$x += 1;
		}
		$x = 0;
	}
	
	$z += 1;
}

close $fh;